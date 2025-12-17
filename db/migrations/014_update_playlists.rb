Sequel.migration do
  change do
    alter_table :playlists do
      add_column :owner, TrueClass, default: false, null: false
    end
  end
end
