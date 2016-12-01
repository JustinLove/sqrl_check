require_relative 'test_helper'

class SQRL::Check::Server::Integrity < SQRL::Check::Server::Test
  IUK = SQRL::Key::IdentityUnlock.new

  class NoncedUrls < SQRL::Check::Server::Test
    def before_all
      @url1 = web_client.upgrade_url(target_url)
      @url2 = web_client.upgrade_url(target_url)
    end

    attr_reader :url1
    attr_reader :url2

    def test_responses_differ
      refute_equal(@url1, @url2)
    end
  end

  class NoncedResponses < SQRL::Check::Server::Test
    def before_all
      session = create_session(target_url, [IUK.identity_master_key])
      @query1 = post(session) {|req| req.query! }
      @query2 = post(session) {|req| req.query! }
    end

    attr_reader :query1
    attr_reader :query2

    assert_known_version :query1

    assert_flags :query2, {
      :id_match               => false,
      :previous_id_match      => false,
      :ip_match               => TRUE,
      :function_not_supported => false,
      :transient_error        => false,
      :command_failed         => false,
      :client_failure         => false,
      :bad_association_id     => false,
    }

    def test_responses_differ
      refute_equal(@query1.params, @query2.params)
    end
  end

  class SingleUse < SQRL::Check::Server::Test
    def before_all
      session = create_session(target_url, [IUK.identity_master_key])
      copy = session.dup
      post(session) {|req| req.query! }
      @replay = post(copy) {|req| req.query! }
    end

    attr_reader :replay

    assert_flags :replay, {
      :ip_match               => TRUE,
      :transient_error        => TRUE,
      :command_failed         => TRUE,
      :client_failure         => false,
    }
  end

  class InvalidIDS < SQRL::Check::Server::Test
    def before_all
      url = web_client.upgrade_url(target_url, )
      bogus_id = SQRL::Key::IdentityUnlock.new
      session = SQRL::ClientSession.new(url, [IUK.identity_master_key])
      bogus_session = SQRL::ClientSession.new(url, [bogus_id.identity_master_key])
      @query = post(session) {|req|
        req.query!
        class << req
          attr_accessor :bogus_key
        end
        req.bogus_key = bogus_session.site_key
        def req.to_hash
          client = encode(client_string)
          server = server_string
          base = client + server
          {
            :client => client,
            :server => server,
            :ids => encode(bogus_key.signature(base)),
            :urs => @ursk && encode(@ursk.signature(base)),
          }.reject {|k,v| v.nil? || v == ''}
        end
        req
      }
    end

    attr_reader :query

    assert_flags :query, {
      :ip_match               => TRUE,
      :transient_error        => false,
      :command_failed         => TRUE,
      :client_failure         => TRUE,
    }
  end

  class InvalidPIDS < SQRL::Check::Server::Test
    def before_all
      url = web_client.upgrade_url(target_url, )
      previous_id = SQRL::Key::IdentityUnlock.new
      bogus_id = SQRL::Key::IdentityUnlock.new
      session = SQRL::ClientSession.new(url, [IUK.identity_master_key, previous_id])
      bogus_session = SQRL::ClientSession.new(url, [bogus_id.identity_master_key])
      @query = post(session) {|req|
        req.query!
        class << req
          attr_accessor :bogus_key
        end
        req.bogus_key = bogus_session.site_key
        def req.to_hash
          client = encode(client_string)
          server = server_string
          base = client + server
          {
            :client => client,
            :server => server,
            :ids => encode(site_key.signature(base)),
            :pids => "x",
            :urs => @ursk && encode(@ursk.signature(base)),
          }.reject {|k,v| v.nil? || v == ''}
        end
        req
      }
    end

    attr_reader :query

    assert_flags :query, {
      :ip_match               => TRUE,
      :transient_error        => false,
      :command_failed         => TRUE,
      :client_failure         => TRUE,
    }
  end

  class InvalidURS < SQRL::Check::Server::Test
    def before_all
      current = SQRL::Key::IdentityUnlock.new
      bogus = SQRL::Key::IdentityUnlock.new
      session = create_session(target_url, [current.identity_master_key])
      lock = current.identity_lock_key.unlock_pair
      @suk = lock[:suk]
      @create = post(session) {|req| req.ident!.setlock(lock) }
      @disable = post(session) {|req| req.disable! }

      session = create_session(target_url, [current.identity_master_key])
      @query = post(session) {|req| req.query! }
      ursk = SQRL::Key::UnlockRequestSigning.new(suk, bogus)
      @enable = post(session) {|req| req.enable!.unlock(ursk) }
      @ident_attempt = post(session) {|req| req.ident! }
    end

    attr_reader :suk
    attr_reader :create
    attr_reader :disable
    attr_reader :enable
    attr_reader :query
    attr_reader :ident_attempt

    assert_flags :create, {
      :command_failed         => false,
    }

    assert_flags :disable, {
      :command_failed         => false,
    }

    assert_known_version :enable

    assert_flags :enable, {
      :ip_match               => TRUE,
      :sqrl_disabled          => TRUE,
      :transient_error        => false,
      :command_failed         => TRUE,
      :client_failure         => TRUE,
    }

    assert_flags :ident_attempt, {
      :ip_match               => TRUE,
      :sqrl_disabled          => TRUE,
      :transient_error        => false,
      :command_failed         => TRUE,
      :client_failure         => false,
    }
  end

  class ModifiedBase64 < SQRL::Check::Server::Test
    def before_all
      session = create_session(target_url, [IUK.identity_master_key])
      post(session) {|req| req.query! }
      session.server_string += 'x'
      @query = post(session) {|req| req.query! }
    end

    attr_reader :query

    assert_flags :query, {
      :ip_match               => false,
      :transient_error        => TRUE,
      :command_failed         => TRUE,
      :client_failure         => false,
    }
  end

  class ModifiedServer < SQRL::Check::Server::Test
    def before_all
      session = create_session(target_url, [IUK.identity_master_key])
      post(session) {|req| req.query! }
      server = SQRL::Base64.decode(session.server_string)
      server += "\r\nfoo=bar"
      session.server_string = SQRL::Base64.encode(server)
      @query = post(session) {|req| req.query! }
      @recovery = post(session) {|req| req.query! }
    end

    attr_reader :query
    attr_reader :recovery

    assert_flags :query, {
      :ip_match               => TRUE,
      :transient_error        => TRUE,
      :command_failed         => TRUE,
      :client_failure         => false,
    }

    assert_flags :recovery, {
      :ip_match               => TRUE,
      :transient_error        => false,
      :command_failed         => false,
      :client_failure         => false,
    }
  end

  class ModifiedUrl < SQRL::Check::Server::Test
    def before_all
      session = create_session(target_url, [IUK.identity_master_key])
      session.server_string += 'x'
      @query = post(session) {|req| req.query! }
    end

    attr_reader :query

    assert_flags :query, {
      :ip_match               => TRUE,
      :transient_error        => TRUE,
      :command_failed         => TRUE,
      :client_failure         => false,
    }
  end
end
