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
  client = SpotifyClient.new(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"])
  spotify_user_id = client.extract_user_id(params[:link]) || params[:spotify_user_id]

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
    link = SpotifyUserPlaylist.first(
      spotify_user_id: spotify_user.id,
      playlist_id: playlist.id,
    )

    snapshot = FetchSpotifyPlaylistSnapshot.new(
      spotify_client: client,
      playlist: playlist,
      spotify_snapshot_id: link.spotify_snapshot_id,
    ).call

    next if snapshot == :unchanged
  end

  redirect "/watch/#{spotify_user_id}"
end

get "/watch/:id" do
  spotify_user = SpotifyUser.first(spotify_user_id: params[:id])

  playlists = spotify_user.playlists

  first_time_per_user = UserPlaylistSnapshotState.where(
    user_id: @current_user.id,
    spotify_user_id: spotify_user.id,
  ).empty?

  results = playlists.map do |playlist|
    # 1. поточний (останній) снапшот
    current_snapshot = playlist
      .playlist_snapshots_dataset
      .order(Sequel.desc(:snapshot_time))
      .first

    # 2. state цього користувача для цього плейліста
    state = UserPlaylistSnapshotState.first(
      user_id: @current_user.id,
      spotify_user_id: spotify_user.id,
      playlist_id: playlist.id,
    )

    previous_snapshot = state&.playlist_snapshot

    presenter = PlaylistPresenter.new(
      playlist: playlist,
      previous_snapshot: previous_snapshot,
      current_snapshot: current_snapshot,
    )

    # 3. ПІСЛЯ порівняння — оновлюємо state
    if current_snapshot
      if state
        state.update(
          playlist_snapshot_id: current_snapshot.id,
          updated_at: Time.now,
        )
      else
        UserPlaylistSnapshotState.create(
          user_id: @current_user.id,
          spotify_user_id: spotify_user.id,
          playlist_id: playlist.id,
          playlist_snapshot_id: current_snapshot.id,
        )
      end
    end

    presenter
  end

  erb :list, locals: {
               spotify_user_id: spotify_user.spotify_user_id,
               user_display_name: spotify_user.display_name,
               user_avatar: spotify_user.avatar_img_url,
               stats: SpotifyUserStats.new(spotify_user),
               results: results,
               first_time_per_user: first_time_per_user,
             }
end
