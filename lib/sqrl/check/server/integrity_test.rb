require_relative 'test_helper'

class SQRL::Check::Server::Integrity < SQRL::Check::Server::Test
  IUK = SQRL::Key::IdentityUnlock.new

  class Nonced < SQRL::Check::Server::Test
    def before_all
      session = create_session(URL, [IUK.identity_master_key])
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
      session = create_session(URL, [IUK.identity_master_key])
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

  class ModifiedBase64 < SQRL::Check::Server::Test
    def before_all
      session = create_session(URL, [IUK.identity_master_key])
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
      session = create_session(URL, [IUK.identity_master_key])
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
      session = create_session(URL, [IUK.identity_master_key])
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
