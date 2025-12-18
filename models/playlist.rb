class Playlist < Sequel::Model
  one_to_many :playlist_snapshots

  one_to_many :spotify_user_playlists
  many_to_many :spotify_users, join_table: :spotify_user_playlists

  one_to_many :user_playlist_snapshot_states
end
