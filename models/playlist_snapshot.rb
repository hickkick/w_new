class PlaylistSnapshot < Sequel::Model
  many_to_one :playlist
  one_to_many :playlist_snapshot_tracks,
              key: :snapshot_id

  one_to_many :user_playlist_snapshot_states
end
