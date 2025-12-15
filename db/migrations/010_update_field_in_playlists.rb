Sequel.migration do
  change do
    alter_table :playlists do
      add_column :image_url, String
    end
  end
end
