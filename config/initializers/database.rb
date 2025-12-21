require "sequel"

environment = ENV.fetch("RACK_ENV", "development")

DB = case environment
  when "production"
    Sequel.connect(ENV.fetch("DATABASE_URL"))
  else
    db_path = File.expand_path("../../../db/dev.sqlite3", __FILE__)
    Sequel.sqlite(db_path)
  end

DB.loggers << LOGGER if defined?(LOGGER) && development?
