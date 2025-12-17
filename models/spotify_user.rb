# class SpotifyUser < Sequel::Model
#   one_to_many :spotify_user_playlists

#   many_to_many :playlists,
#                join_table: :spotify_user_playlists,
#                left_key: :spotify_user_id,
#                right_key: :playlist_id

#   one_to_many :user_spotify_states
# end
class SpotifyUser < Sequel::Model
  one_to_many :spotify_user_playlists

  many_to_many :playlists, join_table: :spotify_user_playlists

  one_to_many :user_playlist_snapshot_states
end
