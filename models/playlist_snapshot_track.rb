class PlaylistSnapshotTrack < Sequel::Model
  set_primary_key [:snapshot_id, :position]
  unrestrict_primary_key
  many_to_one :playlist_snapshot, key: :snapshot_id
  many_to_one :track
end
