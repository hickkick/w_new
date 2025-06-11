require 'dotenv/load'
require_relative 'spotify_client'
require_relative 'playlist_watcher'
require_relative 'snapshot_storage'
require_relative 'snapshot_comparator'

client = SpotifyClient.new(
  ENV['SPOTIFY_CLIENT_ID'],
  ENV['SPOTIFY_CLIENT_SECRET']
)

watcher = PlaylistWatcher.new(client)

puts "Введи Spotify link на профіль друга:"
user_link = gets.strip
user_id = client.extract_user_id(user_link)
storage = SnapshotStorage.new(user_id)

puts "Завантажую плейлісти користувача #{user_id}..."
playlists = watcher.watch_user_playlists(user_id)

playlists.each do |playlist|
  puts playlist["name"]
  tracks = watcher.watch_playlist_tracks(playlist["id"])
  old_snapshot = storage.load(playlist["id"])
  comparison = SnapshotComparator.compare(old_snapshot, tracks)

  puts '*' * 80
  puts "Нові треки:"
  comparison[:added].each { |t| puts "- #{t["track"]["name"]}" }

  puts "Видалені треки:"
  comparison[:removed].each { |t| puts "- #{t["track"]["name"]}" }
  puts '*' * 80
  storage.save(playlist["id"], tracks)
end


