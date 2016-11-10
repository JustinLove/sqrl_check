require_relative 'test_helper'

class SQRL::Check::Server::ReplaceLockedIdentity < SQRL::Check::Server::Test
  def before_all
    current = SQRL::Key::IdentityUnlock.new
    previous = SQRL::Key::IdentityUnlock.new
    session = create_session(URL, [previous.identity_master_key])
    lock = previous.identity_lock_key.unlock_pair
    @suk = lock[:suk]
    @preflight = post(session) {|req| req.ident!.setlock(lock) }

    session = create_session(URL, [current.identity_master_key, previous.identity_master_key])
    @query = post(session) {|req| req.query! }
    ursk = SQRL::Key::UnlockRequestSigning.new(suk, previous)
    @ident = post(session) {|req| req.ident!.unlock(ursk) }
  end

  attr_reader :suk
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

  def test_server_returns_suk
    assert_equal(query.suk, suk.b)
  end

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
