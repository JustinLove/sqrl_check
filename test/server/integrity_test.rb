require_relative 'test_helper'

module CheckSqrlIntegrity
  IUK = SQRL::Key::IdentityUnlock.new

  class Nonced < SqrlTest
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

  class ModifiedBase64 < SqrlTest
    def before_all
      session = create_session(URL, [IUK.identity_master_key])
      post(session) {|req| req.query! }
      session.server_string += 'x'
      @query = post(session) {|req| req.query! }
    end

    attr_reader :query

    assert_flags :query, {
      :transient_error        => TRUE,
      :command_failed         => TRUE,
      :client_failure         => TRUE,
    }
  end

  class ModifiedServer < SqrlTest
    def before_all
      session = create_session(URL, [IUK.identity_master_key])
      post(session) {|req| req.query! }
      server = Base64.decode64(session.server_string)
      server['foo=bar']
      session.server_string += Base64.encode64(server)
      @query = post(session) {|req| req.query! }
    end

    attr_reader :query

    assert_flags :query, {
      :transient_error        => TRUE,
      :command_failed         => TRUE,
      :client_failure         => TRUE,
    }
  end

  class ModifiedUrl < SqrlTest
    def before_all
      session = create_session(URL, [IUK.identity_master_key])
      session.server_string += 'x'
      @query = post(session) {|req| req.query! }
    end

    attr_reader :query

    assert_flags :query, {
      :transient_error        => TRUE,
      :command_failed         => TRUE,
      :client_failure         => TRUE,
    }
  end
end
