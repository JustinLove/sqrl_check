require_relative 'test_helper'

class CheckSqrlQueryWithNewIdentity < SqrlTest
  def before_all
    iuk = SQRL::Key::IdentityUnlock.new
    url = 'http://localhost:3000'
    session = create_session(url, [iuk.identity_master_key])

    @parsed = post(session) {|req| req.query! }
  end

  attr_reader :parsed

  assert_known_version :parsed

  assert_flags :parsed, {
    :id_match               => false,
    :previous_id_match      => false,
    :ip_match               => TRUE,
    #:sqrl_disabled could go either way
    :function_not_supported => false,
    :transient_error        => false,
    :command_failed         => false,
    :client_failure         => false,
    :bad_association_id     => false,
  }
end
