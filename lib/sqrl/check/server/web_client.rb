require 'sqrl/check/server/config'

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
      end
    end
  end
end
