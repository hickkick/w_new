require_relative "./config/boot"

class WNew < Sinatra::Base
  configure do
    set :root, File.dirname(__FILE__)
    set :views, File.join(settings.root, "views")
    set :public_folder, File.join(settings.root, "public")

    enable :sessions
    set :session_secret, ENV.fetch("SESSION_SECRET") {
      if development?
        LOGGER.debug("⚠️  Warning: Using default session secret for development.")
        "local_dev_only_secret"
      else
        raise "CRITICAL: SESSION_SECRET must be set in production!"
      end
    }
  end

  configure :development do
    set :bind, "0.0.0.0"

    register Sinatra::Reloader
    also_reload "./**/*.rb"
    Rack::MiniProfiler.config.position = "left"
    use Rack::MiniProfiler
  end

  helpers SpotifyLinkHelper
  helpers TextHelper
  helpers AuthHelper
  helpers LocaleHelper
  helpers TranslateHelper

  before do
    current_user
    set_locale
  end

  register Routes::Base
  register Routes::Watch
end
