Sequel.migration do
  change do
    create_table :user_playlist_tracking do
      primary_key :id

      foreign_key :user_id, :users, null: false
      foreign_key :spotify_user_id, :spotify_users, null: false

      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP

      index [:user_id, :spotify_user_id], unique: true
      index :user_id
      index :spotify_user_id
    end
  end
end
