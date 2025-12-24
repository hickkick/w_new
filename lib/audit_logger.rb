require "logger"
require "singleton"
require "fileutils"

class AuditLogger
  include Singleton

  def initialize
    FileUtils.mkdir_p("log")

    @logger = Logger.new("log/audit.log")
    @logger.level = Logger::INFO
  end

  def info(data)
    @logger.info(data)
  end

  def warn(data)
    @logger.warn(data)
  end
end
