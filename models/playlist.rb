class Playlist < Sequel::Model
  many_to_one :spotify_user
  one_to_many :playlist_snapshots
  many_to_many :tracks, join_table: :playlist_snapshot_tracks
  one_to_many :user_seen_changes
end
