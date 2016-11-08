require 'minitest/autorun'
require 'minitest/hooks/default'
require 'httpclient'
require 'sqrl/key/identity_unlock'
require 'sqrl/key/unlock_request_signing'
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
  def post(session)
    req = SQRL::QueryGenerator.new(session)
    req = yield req if block_given?
    h = HTTPClient.new(SqrlRequest)
    h.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE if req.post_path.start_with?('qrl://')
    res = h.post(req.post_path, req.post_body)

    SQRL::ResponseParser.new(session, res.body)
  end


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

  def self.assert_flags(response_var, flags)
    flags.each_pair do |name, value|
      define_method "test_#{response_var}_#{name}_is_#{value}" do
        assert_equal(value, send(response_var).send("#{name}?"))
      end
    end
  end

  def self.assert_known_version(response_var)
    define_method :test_known_version do
      assert_equal('1', send(response_var).params['ver'], 'check is only defined for version 1')
    end
  end
end
