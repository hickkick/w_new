Sequel.migration do
  change do
    create_table :user_spotify_states do
      primary_key :id

      foreign_key :user_id, :users, null: false, on_delete: :cascade
      foreign_key :spotify_user_id, :spotify_users, null: false, on_delete: :cascade
      foreign_key :playlist_id, :playlist_snapshots

      DateTime :updated_at
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP

      index [:user_id, :spotify_user_id], unique: true
    end
  end
end
