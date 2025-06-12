require 'dotenv/load'
# app.rb
require 'sinatra'
require 'sinatra/json'
#require 'sinatra/reloader' if development?
configure :development do
  require 'sinatra/reloader'
  also_reload './**/*.rb'
end
require 'securerandom'

require_relative 'spotify_client'
require_relative 'playlist_watcher'
require_relative 'snapshot_storage'
require_relative 'snapshot_comparator'
require_relative 'track_wrapper'
require_relative 'playlist_wrapper'

set :bind, '0.0.0.0'
set :port, 4567
enable :sessions

before do
  session[:user_id] ||= SecureRandom.hex(10)
  puts "Current session user_id: #{session[:user_id]}"
end

get '/' do
  erb :index
end

post '/watch' do
  user_link = params[:link]
  client = SpotifyClient.new(ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'])
  user_id = client.extract_user_id(user_link)
  
  watcher = PlaylistWatcher.new(client)
  playlists = watcher.watch_user_playlists(user_id)
  storage = SnapshotStorage.new(session[:user_id])

  @results = playlists.map do |pl|
    tracks = watcher.watch_playlist_tracks(pl["id"])
    previous_snapshot = storage.load(pl["id"])
    comparison = SnapshotComparator.compare(previous_snapshot, tracks)
   
    storage.save(pl["id"], tracks)

    PlaylistWrapper.new(
    id: pl["id"],
    name: pl["name"],
    total: tracks.size,
    added: comparison[:added],
    removed: comparison[:removed],
    tracks: tracks
  )
  end

  erb :list
end




