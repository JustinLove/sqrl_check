require_relative 'test_helper'

class CheckSqrlQueryWithNewIdentity < SqrlTest
  def before_all
    iuk = SQRL::Key::IdentityUnlock.new
    url = 'http://localhost:3000'
    session = create_session(url, [iuk.identity_master_key])

    @parsed = post(session) {|req| req.query! }
  end

  attr_reader :parsed

  def test_known_version
    assert_equal('1', parsed.params['ver'], 'check is only defined for version 1')
  end

  def test_id_match_should_not_be_set
    assert(!parsed.id_match?)
  end

  def test_prevous_id_match_should_not_be_set
    assert(!parsed.previous_id_match?)
  end

  def test_ip_match_expected
    assert(parsed.ip_match?)
  end

  #sqrl_disabled could go either way

  def test_function_is_supported
    assert(!parsed.function_not_supported?)
  end

  def test_no_transient_error
    assert(!parsed.transient_error?)
  end

  def test_command_succeeded
    assert(!parsed.command_failed?)
  end

  def test_no_client_failure
    assert(!parsed.client_failure?)
  end

  def test_no_association_to_be_bad
    assert(!parsed.bad_association_id?)
  end
end
