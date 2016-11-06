require 'minitest/autorun'
require 'minitest/hooks/default'
require 'httpclient'
require 'sqrl/key/identity_unlock'
require 'sqrl/client_session'
require 'sqrl/query_generator'
require 'sqrl/response_parser'
require 'sqrl/check/version'

class SqrlTest < MiniTest::Test
  include Minitest::Hooks

  SqrlHeaders = {'Content-Type' => 'application/x-www-form-urlencoded'}
  SqrlRequest = {
    :agent_name => "SQRL/1 SQRL::Check/#{SQRL::Check::VERSION}",
    :default_header => SqrlHeaders,
  }

  def create_session(url, imks)
    url = upgrade_url(url)
    SQRL::ClientSession.new(url, imks)
  end

  ScanRequest = {
    :agent_name => "SQRL::Check/#{SQRL::Check::VERSION}",
  }
  def upgrade_url(url)
    return url unless url.start_with?('http')
    h = HTTPClient.new(ScanRequest)
    h.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE if url.start_with?('http://')
    res = h.get(url)
    matches = res.body.match(/"(s?qrl:\/\/[^"]+)"/m)
    if matches
      if matches.length > 2
        puts "multiple matches"
        (1...matches.length).to_a.each do |i|
          puts matches[i]
        end
      end
      return matches[1].gsub('&amp;', '&')
    else
      return url
    end
  end
end

class CheckSqrlQueryWithNewIdentity < SqrlTest
  def before_all
    iuk = SQRL::Key::IdentityUnlock.new
    ilk = iuk.identity_lock_key
    imk = iuk.identity_master_key
    url = 'http://localhost:3000'
    session = create_session(url, [imk])

    req = SQRL::QueryGenerator.new(session).query!
    h = HTTPClient.new(SqrlRequest)
    h.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE if req.post_path.start_with?('qrl://')
    res = h.post(req.post_path, req.post_body)

    @parsed = SQRL::ResponseParser.new(session, res.body)
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
