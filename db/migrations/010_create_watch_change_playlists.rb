Sequel.migration do
  change do
    create_table :watch_change_playlists do
      primary_key :id

      foreign_key :watch_change_id, :watch_changes, null: false, on_delete: :cascade

      foreign_key :playlist_id, :playlists, null: false, on_delete: :cascade
      foreign_key :from_snapshot_id, :playlist_snapshots, null: false, on_delete: :cascade
      foreign_key :to_snapshot_id, :playlist_snapshots, null: false, on_delete: :cascade

      unique [:watch_change_id, :playlist_id]
    end
  end
end
