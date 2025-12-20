require "dotenv/load"
require "sinatra"
require "sinatra/json"

configure :development do
  require "sinatra/reloader"
  also_reload "./**/*.rb"

  require "rack-mini-profiler"
  use Rack::MiniProfiler
end

require_relative "config/logger"
LOGGER.debug("LOGGER come in chat baby!")

require "securerandom"
require "i18n"
require "i18n/backend/simple"

require_relative "helpers/spotify_link_helper"
require_relative "helpers/text_helper"

require_relative "./lib/instrumentation"
require_relative "./lib/spotify_client"
require_relative "./lib/playlist_watcher"
require_relative "./lib/snapshot_storage"
require_relative "./lib/snapshot_comparator"
require_relative "./lib/track_wrapper"
require_relative "./lib/playlist_wrapper"
require_relative "./lib/playlist_statistics"
require_relative "./lib/stats_wrapper"

require_relative "./db/database"

require_relative "./services/user_playlist_changes"
require_relative "./services/fetch_spotify_user_playlists"
require_relative "./services/fetch_spotify_playlist_snapshot"
require_relative "./services/spotify_users_stats"
require_relative "./services/fetch_spotify_user_profile"
require_relative "./services/refresh_spotify_user"
require_relative "./services/watch_page_query"
require_relative "./services/update_user_playlist_snapshot_state"

require_relative "./presenters/track_presenter"
require_relative "./presenters/playlist_presenter"

set :bind, "0.0.0.0"
set :port, ENV.fetch("PORT", 4567)
disable :sessions

helpers SpotifyLinkHelper
helpers TextHelper

configure do
  I18n.load_path += Dir[File.join(settings.root, "locales", "*.yml")]
  I18n.default_locale = :en
  I18n.backend.load_translations
end

before do
  uuid = request.cookies["app_user_id"]

  unless uuid
    uuid = SecureRandom.uuid
    response.set_cookie("app_user_id", value: uuid, path: "/", expires: Time.now + 365 * 24 * 60 * 60)
  end

  @current_user = User.first(uuid: uuid) || User.create(uuid: uuid)

  I18n.locale = request.cookies["lang"]&.to_sym || I18n.default_locale
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
  lang = params[:lang]

  response.set_cookie(
    "lang",
    value: lang,
    path: "/",
    max_age: "31536000",
  )

  redirect params[:redirect_to] || "/"
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
