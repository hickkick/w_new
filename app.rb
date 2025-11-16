require "dotenv/load"
require "sinatra"
require "sinatra/json"

configure :development do
  require "sinatra/reloader"
  also_reload "./**/*.rb"
end

require "securerandom"
require_relative "./lib/spotify_client"
require_relative "./lib/playlist_watcher"
require_relative "./lib/snapshot_storage"
require_relative "./lib/snapshot_comparator"
require_relative "./lib/track_wrapper"
require_relative "./lib/playlist_wrapper"
require_relative "./lib/playlist_statistics"
require_relative "./lib/stats_wrapper"

set :bind, "0.0.0.0"
set :port, ENV.fetch("PORT", 4567)
disable :sessions

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
end

get "/" do
  erb :index
end

post "/watch" do
  user_link = params[:link]
  client = SpotifyClient.new(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"])
  user_id = client.extract_user_id(user_link)

  unless user_id
    @error = "Це не схоже на посилання профілю Spotify. Має виглядати як: https://open.spotify.com/user/username"
    return erb :index
  end

  begin
    watcher = PlaylistWatcher.new(client)
    user_profile = client.fetch_user_profile(user_id)
    @user_display_name = user_profile["display_name"]
    @user_avatar = user_profile["images"]&.first&.dig("url")

    playlists = watcher.watch_user_playlists(user_id)
    storage = SnapshotStorage.new(@user_id)
    @first_time_per_user = playlists.none? { |pl| storage.initialized?(pl["id"]) }

    @results = playlists.map do |pl|
      tracks = watcher.watch_playlist_tracks(pl["id"])
      was_initialized = storage.initialized?(pl["id"])
      previous_snapshot = storage.load(pl["id"])
      comparison = SnapshotComparator.compare(previous_snapshot, tracks)

      storage.save(pl["id"], tracks)

      PlaylistWrapper.new(
        id: pl["id"],
        name: pl["name"],
        total: tracks.size,
        owner_id: pl.dig("owner", "id"),
        image_url: pl.dig("images", 0, "url"),
        added: comparison[:added],
        removed: comparison[:removed],
        tracks: tracks,
        initialized: was_initialized,
      )
    end

    raw_stats = PlaylistStatistics.compute(@results, user_id)
    @stats = StatsWrapper.new(raw_stats)

    erb :list
  rescue => e
    puts "[watch error] #{e.message}"
    @error = "Щось пішло не так при обробці Spotify. #{e.message}"
    erb :index
  end
end
