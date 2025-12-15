Sequel.migration do
  change do
    alter_table :tracks do
      add_column :play_url, String
    end
  end
end
