Sequel.migration do
  change do
    create_table :spotify_users do
      primary_key :id
      String :spotify_user_id, null: false
      String :display_name
      String :avatar_img_url

      DateTime :last_fetched_at
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP

      index :spotify_user_id, unique: true
    end
  end
end
