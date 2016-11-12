require_relative 'test_helper'

class SQRL::Check::Server::EnableUnlocked < SQRL::Check::Server::Test
  def before_all
    current = SQRL::Key::IdentityUnlock.new
    session = create_session(target_url, [current.identity_master_key])
    @create = post(session) {|req| req.ident! }
    @disable = post(session) {|req| req.disable! }

    session = create_session(target_url, [current.identity_master_key])
    @enable = post(session) {|req| req.enable! }

    session = create_session(target_url, [current.identity_master_key])
    @ident_attempt = post(session) {|req| req.ident! }
  end

  attr_reader :create
  attr_reader :disable
  attr_reader :enable
  attr_reader :ident_attempt

  assert_flags :create, {
    :command_failed         => false,
  }

  assert_flags :disable, {
    :command_failed         => false,
  }

  assert_known_version :enable

  assert_flags :enable, {
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

  assert_flags :ident_attempt, {
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
