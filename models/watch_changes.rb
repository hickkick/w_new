class WatchChange < Sequel::Model
  one_to_many :watch_change_playlists
  many_to_one :user
  many_to_one :spotify_user
end
