require 'dotenv/load'
# app.rb
require 'sinatra'
require 'sinatra/json'
require 'sinatra/reloader' if development?

require_relative 'spotify_client'
require_relative 'playlist_watcher'
require_relative 'snapshot_storage'
require_relative 'snapshot_comparator'

set :bind, '0.0.0.0'
set :port, 4567

get '/' do
  erb :index
end

post '/watch' do
  user_link = params[:link]
  client = SpotifyClient.new(ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'])
  user_id = client.extract_user_id(user_link)

  watcher = PlaylistWatcher.new(client)
  playlists = watcher.watch_user_playlists(user_id)

  storage = SnapshotStorage.new(user_id)

  @results = playlists.map do |pl|
    tracks = watcher.watch_playlist_tracks(pl["id"])
    comparison = SnapshotComparator.compare(storage.load(pl["id"]), tracks)
    storage.save(pl["id"], tracks)

    {
      name: pl["name"],
      added: comparison[:added],
      removed: comparison[:removed]
    }
  end

  #json results
  erb :list
end



