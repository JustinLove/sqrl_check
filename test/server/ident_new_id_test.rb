require_relative 'test_helper'

class CheckSqrlIdentWithNewIdentity < SqrlTest
  def before_all
    iuk = SQRL::Key::IdentityUnlock.new
    url = 'http://localhost:3000'
    session = create_session(url, [iuk.identity_master_key])

    @query = post(session) {|req| req.query! }
    @ident = post(session) {|req| req.ident! }
  end

  attr_reader :query
  attr_reader :ident

  def test_known_version
    assert_equal('1', query.params['ver'], 'check is only defined for version 1')
  end

  def test_query_id_does_not_match
    assert(!query.id_match? && !query.previous_id_match?)
  end

  def test_id_match_should_be_set
    assert(ident.id_match?)
  end

  def test_prevous_id_match_should_not_be_set
    assert(!ident.previous_id_match?)
  end

  def test_ip_match_expected
    assert(ident.ip_match?)
  end

  def test_sqrl_enabled
    assert(!ident.sqrl_disabled?)
  end

  def test_function_is_supported
    assert(!ident.function_not_supported?)
  end

  def test_no_transient_error
    assert(!ident.transient_error?)
  end

  def test_command_succeeded
    assert(!ident.command_failed?)
  end

  def test_no_client_failure
    assert(!ident.client_failure?)
  end

  def test_association_is_not_bad
    assert(!ident.bad_association_id?)
  end
end
