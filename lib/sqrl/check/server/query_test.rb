require_relative 'test_helper'

class SQRL::Check::Server::QueryWithNewIdentity < SQRL::Check::Server::Test
  def before_all
    iuk = SQRL::Key::IdentityUnlock.new
    @url = web_client.upgrade_url(target_url)
    session = create_session(@url, [iuk.identity_master_key])

    @parsed = post(session) {|req| req.query! }
  end

  attr_reader :url
  attr_reader :parsed

  assert_known_version :parsed

  def test_sfn_is_present_and_base64_encoded
    obj = SQRL::URL.parse(url)
    params = Hash[URI.decode_www_form(obj.query)]
    assert(params['sfn'])
    assert(SQRL::Base64.decode(params['sfn']))
  end

  def test_ver_must_be_the_first_parameter
    assert_equal(@parsed.params.keys.index('ver'), 0)
  end

  def test_response_must_include_nut_parameter
    assert_includes(@parsed.params.keys, 'nut')
  end

  def test_response_must_include_tif_parameter
    assert_includes(@parsed.params.keys, 'tif')
  end

  def test_response_must_include_qry_parameter
    assert_includes(@parsed.params.keys, 'qry')
  end

  def test_response_qry_should_not_include_scheme_host_or_port
    uri = URI(@parsed.params['qry'])
    assert_nil(uri.scheme)
    assert_nil(uri.host)
    assert_nil(uri.port)
  end

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
