class SpotifyUser < Sequel::Model
  one_to_many :spotify_user_playlists

  many_to_many :playlists, join_table: :spotify_user_playlists

  one_to_many :user_playlist_snapshot_states
end
