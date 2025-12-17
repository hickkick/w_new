# class Playlist < Sequel::Model
#   one_to_many :spotify_user_playlists

#   many_to_many :spotify_users,
#                join_table: :spotify_user_playlists,
#                left_key: :playlist_id,
#                right_key: :spotify_user_id

#   one_to_many :playlist_snapshots

#   many_to_many :tracks, join_table: :playlist_snapshot_tracks

#   one_to_many :user_playlist_snapsot_states
# end
class Playlist < Sequel::Model
  one_to_many :playlist_snapshots

  one_to_many :spotify_user_playlists
  many_to_many :spotify_users, join_table: :spotify_user_playlists

  one_to_many :user_playlist_snapshot_states
end
