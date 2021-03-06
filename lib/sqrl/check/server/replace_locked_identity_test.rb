require_relative 'test_helper'

class SQRL::Check::Server::ReplaceLockedIdentity < SQRL::Check::Server::Test
  def before_all
    current = SQRL::Key::IdentityUnlock.new
    previous = SQRL::Key::IdentityUnlock.new
    session = create_session(target_url, [previous.identity_master_key])
    lock = previous.identity_lock_key.unlock_pair
    @suk = lock[:suk]
    @preflight = post(session) {|req| req.ident!.setlock(lock) }

    session = create_session(target_url, [current.identity_master_key, previous.identity_master_key])
    @locked_ident = post(session) {|req| req.ident! }

    session = create_session(target_url, [current.identity_master_key, previous.identity_master_key])
    @query = post(session) {|req| req.query! }
    ursk = SQRL::Key::UnlockRequestSigning.new(suk, previous)
    @ident = post(session) {|req| req.ident!.unlock(ursk) }
  end

  attr_reader :suk
  attr_reader :preflight
  attr_reader :locked_ident
  attr_reader :query
  attr_reader :ident

  assert_flags :preflight, {
    :command_failed         => false,
  }

  assert_flags :locked_ident, {
    :id_match               => false,
    :previous_id_match      => TRUE,
    :command_failed         => false,
  }

  assert_known_version :query

  assert_flags :query, {
    :id_match               => false,
    :previous_id_match      => TRUE,
  }

  def test_server_return_suk_when_identified_by_pidk
    assert_equal(suk.b, query.suk)
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
