require "sequel"

environment = ENV.fetch("RACK_ENV", "development")

DB = case environment
  when "production"
    Sequel.connect(ENV.fetch("DATABASE_URL"))
  else
    Sequel.sqlite("db/dev.sqlite3")
  end

Dir["./models/*.rb"].each { |f| require f }
