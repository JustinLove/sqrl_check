require_relative 'test_helper'

class CheckSqrlIdentWithExistingIdentity < SqrlTest
  def before_all
    iuk = SQRL::Key::IdentityUnlock.new
    url = 'http://localhost:3000'
    session = create_session(url, [iuk.identity_master_key])
    @preflight = post(session) {|req| req.ident! }

    session = create_session(url, [iuk.identity_master_key])
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
    :id_match               => TRUE,
    :previous_id_match      => false,
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