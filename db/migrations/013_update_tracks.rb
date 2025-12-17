Sequel.migration do
  change do
    alter_table :tracks do
      drop_column :added_at
    end
  end
end
