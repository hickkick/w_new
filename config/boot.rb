APP_ROOT = File.expand_path("..", __dir__)

require "bundler/setup"
Bundler.require(:default, ENV["RACK_ENV"] || :development)

if defined?(Dotenv)
  Dotenv.load(File.join(APP_ROOT, ".env"))
end

Dir[File.join(APP_ROOT, "config", "initializers", "*.rb")].each { |f| require f }

current_env = ENV["RACK_ENV"] || "development"
env_file = File.join(APP_ROOT, "config", "environments", "#{current_env}.rb")
require env_file if File.exist?(env_file)

%w[lib helpers models services presenters].each do |dir|
  Dir["#{APP_ROOT}/#{dir}/**/*.rb"].each { |f| require f }
end
