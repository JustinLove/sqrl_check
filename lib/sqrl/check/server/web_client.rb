require 'sqrl/check/server/config'
require 'sqrl/check/version'
require 'sqrl/query_generator'
require 'sqrl/response_parser'
require 'httpclient'

module SQRL
  module Check
    module Server
      class WebClient
        def initialize(options = {})
          self.target_url = options[:target_url] if options[:target_url]
          self.signed_cert = options[:signed_cert] if !options[:signed_cert].nil?
        end

        attr_writer :target_url
        attr_writer :signed_cert

        def target_url
          @target_url ||= Config.target_url
        end

        def signed_cert?
          @signed_cert = Config.signed_cert? if @signed_cert.nil?
          @signed_cert
        end

        SqrlHeaders = {'Content-Type' => 'application/x-www-form-urlencoded'}
        SqrlRequest = {
          :agent_name => "SQRL/1 SQRL::Check/#{SQRL::Check::VERSION}",
          :default_header => SqrlHeaders,
        }
        def post(session)
          req = SQRL::QueryGenerator.new(session)
          req = yield req if block_given?
          h = HTTPClient.new(SqrlRequest)
          h.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE unless signed_cert?
          res = h.post(req.post_path, req.post_body)

          SQRL::ResponseParser.new(res.body).update_session(session)
        end

        ScanRequest = {
          :agent_name => "SQRL::Check/#{SQRL::Check::VERSION}",
        }
        def fetch(url)
          h = HTTPClient.new(ScanRequest)
          h.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE unless signed_cert?
          h.get(url)
        end

        def upgrade_url(url)
          return url unless url.start_with?('http')
          res = fetch(url)
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
    end
  end
end
