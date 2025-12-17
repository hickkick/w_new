class UserPlaylistSnapshotState < Sequel::Model
  many_to_one :user
  many_to_one :playlist
  many_to_one :playlist_snapshot
end
