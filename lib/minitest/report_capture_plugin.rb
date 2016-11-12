module Minitest
  def self.plugin_report_capture_options(opts, options)
    opts.on "--quiet", "Shut down default reporters" do
      options[:quiet] = true
    end
  end

  def self.plugin_report_capture_init(options)
    self.reporter.reporters = [] if options[:quiet]
    self.reporter << self.capture
  end

  class CaptureReporter < StatisticsReporter
  end

  class <<self
    attr_accessor :capture
  end

  self.capture = CaptureReporter.new
end
