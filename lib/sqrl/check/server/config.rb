module SQRL
  module Check
    module Server
      module Config
        class << self
          attr_accessor :target_url
          attr_accessor :signed_cert
        end

        self.target_url = ENV['SQRL_CHECK_URL'] || 'http://localhost:3000'
        self.signed_cert = !!ENV['SQRL_CHECK_SIGNED_CERT']

        def self.signed_cert?
          signed_cert
        end

        def self.config(options = {})
          self.target_url = options[:target_url] if options[:target_url]
          self.signed_cert = options[:signed_cert] if !options[:signed_cert].nil?
        end
      end
    end
  end
end
