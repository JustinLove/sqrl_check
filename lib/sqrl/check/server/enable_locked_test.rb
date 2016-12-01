require_relative 'test_helper'

class SQRL::Check::Server::EnableLocked < SQRL::Check::Server::Test
  def before_all
    current = SQRL::Key::IdentityUnlock.new
    session = create_session(target_url, [current.identity_master_key])
    lock = current.identity_lock_key.unlock_pair
    @suk = lock[:suk]
    @create = post(session) {|req| req.ident!.setlock(lock) }
    @disable = post(session) {|req| req.disable! }

    session = create_session(target_url, [current.identity_master_key])
    @locked_enable = post(session) {|req| req.enable! }
    @locked_ident_attempt = post(session) {|req| req.ident! }

    session = create_session(target_url, [current.identity_master_key])
    @query = post(session) {|req| req.query! }
    ursk = SQRL::Key::UnlockRequestSigning.new(suk, current)
    @enable = post(session) {|req| req.enable!.unlock(ursk) }
    @ident_attempt = post(session) {|req| req.ident! }
  end

  attr_reader :suk
  attr_reader :create
  attr_reader :disable
  attr_reader :locked_enable
  attr_reader :locked_ident_attempt
  attr_reader :query
  attr_reader :enable
  attr_reader :ident_attempt

  assert_flags :create, {
    :command_failed         => false,
  }

  assert_flags :disable, {
    :command_failed         => false,
  }

  assert_known_version :enable

  def test_server_should_return_suk_on_disabled_account
    assert_equal(suk.b, query.suk)
  end

  assert_flags :locked_enable, {
    :command_failed         => TRUE,
    :sqrl_disabled          => TRUE,
  }

  assert_flags :locked_ident_attempt, {
    :command_failed         => TRUE,
    :sqrl_disabled          => TRUE,
  }

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
