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

require_relative "./services/user_playlist_changes"
require_relative "./services/fetch_spotify_user_playlists"
require_relative "./services/fetch_spotify_playlist_snapshot"
require_relative "./services/spotify_users_stats"
require_relative "./services/fetch_spotify_user_profile"

require_relative "./presenters/track_presenter"
require_relative "./presenters/playlist_presenter"

set :bind, "0.0.0.0"
set :port, ENV.fetch("PORT", 4567)
disable :sessions

configure do
  I18n.load_path += Dir[File.join(settings.root, "locales", "*.yml")]
  I18n.default_locale = :en
  I18n.backend.load_translations
end

before do
  # user_id = request.cookies["app_user_id"]

  # unless user_id
  #   user_id = SecureRandom.uuid
  #   response.set_cookie(
  #     "app_user_id",
  #     value: user_id,
  #     path: "/",
  #     expires: Time.now + 365 * 24 * 60 * 60, # 1 year
  #   )
  #   puts "Assigned NEW persistent user_id: #{user_id}"
  # else
  #   puts "Existing persistent user_id: #{user_id}"
  # end

  # @user_id = user_id

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

  def first_time_per_user?(user, spotify_user)
    playlists_ids = spotify_user.playlists_dataset.select_map(:id)

    UserSeenChange
      .where(user_id: user.id, playlist_id: playlists_ids)
      .count == 0
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

  erb :list, locals: {
               user_display_name: @user_display_name,
               user_avatar: @user_avatar,
               stats: @stats,
               results: @results,
               first_time_per_user: @first_time_per_user,
             }
end

# get "/spotify/:spotify_user_id" do
#   spotify_user_id = params[:spotify_user_id]

#   client = SpotifyClient.new(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"])

#   # 1. наш локальний користувач (з cookie)
#   user = User.first(id: @current_user.id) || User.create(id: @current_user)

#   # 2. Spotify user
#   spotify_user = SpotifyUser.find_or_create(
#     spotify_user_id: spotify_user_id,
#   )

#   # 3. ФЕТЧ ПЛЕЙЛИСТІВ
#   FetchSpotifyUserPlaylists.new(
#     spotify_client: client,
#     spotify_user: spotify_user,
#   ).call

#   # 4. Для кожного плейлиста — snapshot + diff
#   results = spotify_user.playlists.map do |playlist|
#     snapshot_result = FetchSpotifyPlaylistSnapshot.new(
#       spotify_client: client,
#       playlist: playlist,
#     ).call

#     changes = UserPlaylistChanges.new(user, playlist)

#     {
#       playlist: playlist,
#       snapshot_created: snapshot_result != :unchanged,
#       added_tracks: changes.added,
#       removed_tracks: changes.removed,
#     }
#   end

#   erb :spotify_user, locals: {
#                        spotify_user: spotify_user,
#                        results: results,
#                      }
# end

post "/watch/:spotify_user_id" do
  client = SpotifyClient.new(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"])
  spotify_user_id = client.extract_user_id(params[:link])

  spotify_user = SpotifyUser.find_or_create(
    spotify_user_id: spotify_user_id,
  )

  FetchSpotifyUserProfile.new(
    spotify_client: client,
    spotify_user: spotify_user,
  ).call

  playlists = FetchSpotifyUserPlaylists.new(
    spotify_client: client,
    spotify_user: spotify_user,
  ).call

  playlists.each do |playlist|
    FetchSpotifyPlaylistSnapshot.new(
      spotify_client: client,
      playlist: playlist,
    ).call

    state = UserPlaylistSnapshotState.first(
      user_id: @current_user.id,
      playlist_id: playlist.id,
    )

    if state
      state.update(
        playlist_snapshot_id: snapshot.id,
        updated_at: Time.now,
      )
    else
      UserPlaylistSnapshotState.create(
        user_id: @current_user.id,
        playlist_id: playlist.id,
        playlist_snapshot_id: snapshot.id,
      )
    end
  end

  redirect "/watch/#{spotify_user_id}"
end

get "/watch/:id" do
  spotify_user = SpotifyUser.first(spotify_user_id: params[:id])

  playlists = spotify_user.playlists

  results = playlists.map do |playlist|
    # поточний снапшот
    current_snapshot = playlist
      .playlist_snapshots_dataset
      .order(Sequel.desc(:snapshot_time))
      .first

    # state для цього user + playlist
    state = UserPlaylistSnapshotState.first(
      user_id: @current_user.id,
      playlist_id: playlist.id,
    )

    previous_snapshot = state&.playlist_snapshot

    PlaylistPresenter.new(
      playlist: playlist,
      previous_snapshot: previous_snapshot,
      current_snapshot: current_snapshot,
    )
  end

  erb :list, locals: {
               user_display_name: spotify_user.display_name,
               user_avatar: spotify_user.avatar_img_url,
               stats: SpotifyUserStats.new(spotify_user),
               results: results,
               first_time_per_user: results.all? { |r| r.added.empty? && r.removed.empty? },
             }
end
