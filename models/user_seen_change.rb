class UserSeenChange < Sequel::Model
  unrestrict_primary_key

  many_to_one :user
  many_to_one :playlist
  many_to_one :last_seen_snapshot, class: :PlaylistSnapshot, key: :last_seen_snapshot_id
end
