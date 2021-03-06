require_relative 'test_helper'

class SQRL::Check::Server::RemoveLockedIdentity < SQRL::Check::Server::Test
  def before_all
    current = SQRL::Key::IdentityUnlock.new
    session = create_session(target_url, [current.identity_master_key])
    lock = current.identity_lock_key.unlock_pair
    @suk = lock[:suk]
    @create = post(session) {|req| req.ident!.setlock(lock) }

    session = create_session(target_url, [current.identity_master_key])
    @locked_remove = post(session) {|req| req.remove! }

    session = create_session(target_url, [current.identity_master_key])
    @query = post(session) {|req| req.query!.opt('suk') }
    ursk = SQRL::Key::UnlockRequestSigning.new(suk, current)
    @remove = post(session) {|req| req.remove!.unlock(ursk) }
  end

  attr_reader :suk
  attr_reader :create
  attr_reader :locked_remove
  attr_reader :query
  attr_reader :remove

  assert_flags :create, {
    :command_failed         => false,
  }

  assert_flags :locked_remove, {
    :command_failed         => TRUE,
  }

  assert_known_version :query

  assert_flags :query, {
    :id_match               => TRUE,
    :previous_id_match      => false,
    :command_failed         => false,
  }

  def test_server_should_return_suk_when_requested
    assert_equal(suk.b, query.suk)
  end

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
