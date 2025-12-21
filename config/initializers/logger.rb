require "logger"

LOGGER ||= Logger.new($stdout)
LOGGER.level = if ENV["RACK_ENV"] == "production"
    Logger::INFO
  else
    Logger::DEBUG
  end

LOGGER.formatter = proc do |severity, time, progname, msg|
  "[#{time.strftime("%H:%M:%S")}] #{severity}: #{msg}\n"
end
