require 'minitest'
require 'minitest/hooks/default'
require 'sqrl/key/identity_unlock'
require 'sqrl/key/unlock_request_signing'
require 'sqrl/client_session'
require 'sqrl/base64'
require 'sqrl/check/server/web_client'

module SQRL::Check::Server; end

class SQRL::Check::Server::Test < Minitest::Test
  include Minitest::Hooks

  def web_client
    @web_client ||= SQRL::Check::Server::WebClient.new
  end

  def target_url
    web_client.target_url
  end

  def create_session(url, imks)
    url = web_client.upgrade_url(url)
    SQRL::ClientSession.new(url, imks)
  end

  def post(session, &config)
    web_client.post(session, &config)
  end

  def self.assert_flags(response_var, flags)
    flags.each_pair do |name, value|
      define_method "test_#{response_var}_response_TIF_#{name}_should_be_#{value}" do
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

if $PROGRAM_NAME.match(/_test\.rb|rake_test_loader\.rb/)
  Minitest.autorun
end
