Sequel.migration do
  change do
    create_table :playlists do
      primary_key :id

      String :playlist_id, null: false
      foreign_key :spotify_user_id, :spotify_users, null: false
      String :playlist_snapshot_id

      String :name
      String :description
      DateTime :last_fetched_at
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP

      index :playlist_id, unique: true
      index :spotify_user_id
    end
  end
end
