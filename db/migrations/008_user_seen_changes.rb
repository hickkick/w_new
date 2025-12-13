Sequel.migration do
  change do
    create_table :user_seen_changes do
      foreign_key :user_id, :users, null: false, on_delete: :cascade
      foreign_key :playlist_id, :playlists, null: false, on_delete: :cascade

      foreign_key :last_seen_snapshot_id, :playlist_snapshots, on_delete: :set_null

      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP

      primary_key [:user_id, :playlist_id]
    end
  end
end
