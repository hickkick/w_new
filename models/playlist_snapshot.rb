class PlaylistSnapshot < Sequel::Model
  many_to_one :playlist

  many_to_many :tracks,
               join_table: :playlist_snapshot_tracks,
               left_key: :snapshot_id,
               right_key: :track_id

  one_to_many :playlist_snapshot_tracks,
              key: :snapshot_id

  one_to_many :user_playlist_snapsot_states
end
