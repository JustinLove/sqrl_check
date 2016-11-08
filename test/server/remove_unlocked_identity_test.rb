require_relative 'test_helper'

class CheckSqrlRemoveUnlockedIdentity < SqrlTest
  def before_all
    current = SQRL::Key::IdentityUnlock.new
    url = 'http://localhost:3000'
    session = create_session(url, [current.identity_master_key])
    @preflight = post(session) {|req| req.ident! }

    session = create_session(url, [current.identity_master_key])
    @query = post(session) {|req| req.query! }
    @remove = post(session) {|req| req.remove! }
  end

  attr_reader :preflight
  attr_reader :query
  attr_reader :remove

  assert_flags :preflight, {
    :command_failed         => false,
  }

  assert_known_version :query

  assert_flags :query, {
    :id_match               => TRUE,
    :previous_id_match      => false,
  }

  assert_flags :remove, {
    :id_match               => false,
    :previous_id_match      => false,
    :ip_match               => TRUE,
    :sqrl_disabled          => false,
    :function_not_supported => false,
    :transient_error        => false,
    :command_failed         => false,
    :client_failure         => false,
    :bad_association_id     => false,
  }
end
