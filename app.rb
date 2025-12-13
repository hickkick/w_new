require "dotenv/load"
require "sinatra"
require "sinatra/json"

configure :development do
  require "sinatra/reloader"
  also_reload "./**/*.rb"
end

require "securerandom"
require "i18n"
require "i18n/backend/simple"

require_relative "./lib/spotify_client"
require_relative "./lib/playlist_watcher"
require_relative "./lib/snapshot_storage"
require_relative "./lib/snapshot_comparator"
require_relative "./lib/track_wrapper"
require_relative "./lib/playlist_wrapper"
require_relative "./lib/playlist_statistics"
require_relative "./lib/stats_wrapper"

require_relative "./db/database"

set :bind, "0.0.0.0"
set :port, ENV.fetch("PORT", 4567)
disable :sessions

configure do
  I18n.load_path += Dir[File.join(settings.root, "locales", "*.yml")]
  I18n.default_locale = :en
  I18n.backend.load_translations
end

before do
  user_id = request.cookies["app_user_id"]

  unless user_id
    user_id = SecureRandom.uuid
    response.set_cookie(
      "app_user_id",
      value: user_id,
      path: "/",
      expires: Time.now + 365 * 24 * 60 * 60, # 1 year
    )
    puts "Assigned NEW persistent user_id: #{user_id}"
  else
    puts "Existing persistent user_id: #{user_id}"
  end

  @user_id = user_id

  I18n.locale = request.cookies["lang"]&.to_sym || I18n.default_locale
end

helpers do
  def t(key, **opts)
    I18n.t(key, **opts)
  end
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
  link = params[:link]
  client = SpotifyClient.new(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"])

  user_id = client.extract_user_id(link)

  if user_id.nil?
    @error = I18n.t("errors.invalid_link")
    return erb :index
  end

  response.set_cookie("spotify_user_id", value: user_id, path: "/", max_age: "31536000")

  redirect "/watch"
end

get "/watch" do
  user_id = request.cookies["spotify_user_id"]

  redirect "/" unless user_id

  client = SpotifyClient.new(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"])
  watcher = PlaylistWatcher.new(client)

  user_profile = client.fetch_user_profile(user_id)

  @user_display_name = user_profile["display_name"]
  @user_avatar = user_profile["images"]&.first&.dig("url")

  playlists = watcher.watch_user_playlists(user_id)

  storage = SnapshotStorage.new(request.cookies["app_user_id"])
  @first_time_per_user = playlists.none? { |pl| storage.initialized?(pl["id"]) }

  @results = playlists.map do |pl|
    tracks = watcher.watch_playlist_tracks(pl["id"])
    was_initialized = storage.initialized?(pl["id"])
    prev = storage.load(pl["id"])
    diff = SnapshotComparator.compare(prev, tracks)
    storage.save(pl["id"], tracks)

    PlaylistWrapper.new(
      id: pl["id"],
      name: pl["name"],
      total: tracks.size,
      owner_id: pl.dig("owner", "id"),
      image_url: pl.dig("images", 0, "url"),
      added: diff[:added],
      removed: diff[:removed],
      tracks: tracks,
      initialized: was_initialized,
    )
  end

  stats_raw = PlaylistStatistics.compute(@results, user_id)
  @stats = StatsWrapper.new(stats_raw)

  erb :list
end
