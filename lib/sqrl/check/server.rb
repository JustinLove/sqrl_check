Dir[File.expand_path('../server/*_test.rb', __FILE__)].each do |path|
  require path
end

module SQRL
  module Check
    module Server
      def self.run
        Minitest.run ["--quiet"]
        Minitest.capture
      end

      def self.autorun
        Minitest.autorun
      end
    end
  end
end
