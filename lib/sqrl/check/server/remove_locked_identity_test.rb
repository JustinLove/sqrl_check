require_relative 'test_helper'

class SQRL::Check::Server::RemoveLockedIdentity < SQRL::Check::Server::Test
  def before_all
    current = SQRL::Key::IdentityUnlock.new
    session = create_session(URL, [current.identity_master_key])
    lock = current.identity_lock_key.unlock_pair
    @suk = lock[:suk]
    @create = post(session) {|req| req.ident!.setlock(lock) }

    session = create_session(URL, [current.identity_master_key])
    @query = post(session) {|req| req.query!.opt('suk') }
    ursk = SQRL::Key::UnlockRequestSigning.new(suk, current)
    @remove = post(session) {|req| req.remove!.unlock(ursk) }
  end

  attr_reader :suk
  attr_reader :create
  attr_reader :query
  attr_reader :remove

  assert_flags :create, {
    :command_failed         => false,
  }

  assert_known_version :query

  assert_flags :query, {
    :id_match               => TRUE,
    :previous_id_match      => false,
  }

  def test_server_returns_suk
    assert_equal(query.suk, suk.b)
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
