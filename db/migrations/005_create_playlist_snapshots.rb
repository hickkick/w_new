# Sequel.migration do
#   change do
#     create_table :playlist_snapshots do
#       primary_key :id

#       foreign_key :playlist_id, :playlists, null: false

#       String :spotify_snapshot_id
#       DateTime :snapshot_time, default: Sequel::CURRENT_TIMESTAMP
#       DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP

#       index :playlist_id
#       index [:playlist_id, :snapshot_time]
#     end
#   end
# end
Sequel.migration do
  change do
    create_table :playlist_snapshots do
      primary_key :id
      foreign_key :playlist_id, :playlists, null: false, on_delete: :cascade

      String :spotify_snapshot_id
      DateTime :snapshot_time, default: Sequel::CURRENT_TIMESTAMP
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP

      index [:playlist_id, :snapshot_time]
    end
  end
end
