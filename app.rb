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

  before do
    current_user
    set_locale
  end

  helpers do
    def t(key, **opts)
      I18n.t(key, **opts)
    end

    # def show_error(key)
    #   @error = t(key)
    #   erb :index
    # end
  end

  get "/" do
    erb :index
  end

  get "/set_lang" do
    lang = params[:lang].to_sym

    if I18n.available_locales.include?(lang)
      session[:locale] = lang
    end

    redirect params[:redirect_to] || back || "/"
  end

  post "/watch" do
    link = params[:link]&.strip

    if link.nil? || link.empty?
      @error = t("errors.empty_link")
      return erb :index
    end

    spotify_user_id = extract_spotify_user_id(link)

    unless spotify_user_id
      @error = t("errors.invalid_spotify_link")
      return erb :index
    end

    begin
      client = SpotifyClient.new(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"])

      RefreshSpotifyUser.new(
        spotify_user_id: spotify_user_id,
        client: client,
      ).call

      redirect "/watch/#{spotify_user_id}"
    rescue SpotifyClient::NotFoundError
      @error = t("errors.user_not_found", username: spotify_user_id)
      erb :index
    rescue => e
      @error = t("errors.unexpected_error")
      erb :index
    end
  end

  post "/watch/:id" do
    client = SpotifyClient.new(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"])
    spotify_user_id = params[:id]

    RefreshSpotifyUser.new(
      spotify_user_id: spotify_user_id,
      client: client,
    ).call

    redirect "/watch/#{spotify_user_id}"
  end

  get "/watch/:id" do
    spotify_user = SpotifyUser.first(spotify_user_id: params[:id])
    halt 404 unless spotify_user

    page = WatchPageQuery.new(
      spotify_user: spotify_user,
      current_user: @current_user,
    ).call

    UpdateUserPlaylistSnapshotState.new(
      user: @current_user,
      spotify_user: spotify_user,
      playlists: spotify_user.playlists,
    ).call

    erb :list, locals: {
                 spotify_user_id: spotify_user.spotify_user_id,
                 user_display_name: spotify_user.display_name,
                 user_avatar: spotify_user.avatar_img_url,
                 stats: SpotifyUserStats.new(spotify_user),
                 results: page[:results],
                 first_time_per_user: page[:first_time_per_user],
               }
  end
end
