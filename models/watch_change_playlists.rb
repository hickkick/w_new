class WatchChangePlaylist < Sequel::Model
  many_to_one :watch_change
  many_to_one :playlist
  many_to_one :from_snapshot, class: :PlaylistSnapshot, key: :from_snapshot_id
  many_to_one :to_snapshot, class: :PlaylistSnapshot, key: :to_snapshot_id
end
