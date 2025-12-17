Sequel.migration do
  change do
    alter_table :playlist_snapshot_tracks do
      add_column :added_at, DateTime
    end
  end
end
