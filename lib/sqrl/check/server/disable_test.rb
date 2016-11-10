require_relative 'test_helper'

class SQRL::Check::Server::Disable < SQRL::Check::Server::Test
  def before_all
    current = SQRL::Key::IdentityUnlock.new
    session = create_session(URL, [current.identity_master_key])
    @preflight = post(session) {|req| req.ident! }

    session = create_session(URL, [current.identity_master_key])
    @disable = post(session) {|req| req.disable! }

    session = create_session(URL, [current.identity_master_key])
    @ident_attempt = post(session) {|req| req.ident! }
  end

  attr_reader :preflight
  attr_reader :disable
  attr_reader :ident_attempt

  assert_flags :preflight, {
    :command_failed         => false,
  }

  assert_known_version :disable

  assert_flags :disable, {
    :id_match               => TRUE,
    :previous_id_match      => false,
    :ip_match               => TRUE,
    :sqrl_disabled          => TRUE,
    :function_not_supported => false,
    :transient_error        => false,
    :command_failed         => false,
    :client_failure         => false,
    :bad_association_id     => false,
  }

  assert_flags :ident_attempt, {
    :id_match               => TRUE,
    :previous_id_match      => false,
    :ip_match               => TRUE,
    :sqrl_disabled          => TRUE,
    :function_not_supported => false,
    :transient_error        => false,
    :command_failed         => TRUE,
    :client_failure         => false,
    :bad_association_id     => false,
  }
end
