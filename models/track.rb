class Track < Sequel::Model
  many_to_many :playlist_snapshots,
               join_table: :playlist_snapshot_tracks,
               left_key: :track_id,
               right_key: :snapshot_id
end
