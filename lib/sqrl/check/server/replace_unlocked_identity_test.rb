require_relative 'test_helper'

class SQRL::Check::Server::ReplaceUnlockedIdentity < SQRL::Check::Server::Test
  def before_all
    current = SQRL::Key::IdentityUnlock.new
    previous = SQRL::Key::IdentityUnlock.new
    session = create_session(URL, [previous.identity_master_key])
    @preflight = post(session) {|req| req.ident! }

    session = create_session(URL, [current.identity_master_key, previous.identity_master_key])
    @query = post(session) {|req| req.query! }
    @ident = post(session) {|req| req.ident! }
  end

  attr_reader :preflight
  attr_reader :query
  attr_reader :ident

  assert_flags :preflight, {
    :command_failed         => false,
  }

  assert_known_version :query

  assert_flags :query, {
    :id_match               => false,
    :previous_id_match      => TRUE,
  }

  assert_flags :ident, {
    :id_match               => TRUE,
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
