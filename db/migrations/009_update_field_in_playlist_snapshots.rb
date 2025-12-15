Sequel.migration do
  change do
    alter_table :playlist_snapshots do
      add_column :spotify_snapshot_id, String
    end
  end
end
