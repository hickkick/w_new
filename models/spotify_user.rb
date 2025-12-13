class SpotifyUser < Sequel::Model
  one_to_many :playlists

  one_to_many :user_playlist_trackings
  many_to_many :users,
    join_table: :user_playlist_tracking
end
