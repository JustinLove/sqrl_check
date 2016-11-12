require 'sqrl/check/server/config'
Dir[File.expand_path('../server/*_test.rb', __FILE__)].each do |path|
  require path
end

module SQRL
  module Check
    module Server
      def self.run(config = {})
        Config.config(config)
        Minitest.run ["--quiet"]
        Minitest.capture
      end

      def self.autorun(config = {})
        Config.config(config)
        Minitest.autorun
      end
    end
  end
end
