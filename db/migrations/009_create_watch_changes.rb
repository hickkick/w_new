Sequel.migration do
  change do
    create_table :watch_changes do
      primary_key :id

      foreign_key :user_id, :users, null: false, on_delete: :cascade
      foreign_key :spotify_user_id, :spotify_users, null: false, on_delete: :cascade

      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
