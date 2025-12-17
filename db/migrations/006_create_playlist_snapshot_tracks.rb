Sequel.migration do
  change do
    create_table :playlist_snapshot_tracks do
      Integer :position, null: false
      foreign_key :snapshot_id, :playlist_snapshots, null: false, on_delete: :cascade
      foreign_key :track_id, :tracks, null: false, on_delete: :cascade

      primary_key [:snapshot_id, :position]
    end
  end
end
