Sequel.migration do
  change do
    # Створюємо join table
    create_table :spotify_user_playlists do
      Integer :spotify_user_id, null: false
      Integer :playlist_id, null: false
      TrueClass :owner, default: false, null: false
      DateTime :added_at, default: Sequel::CURRENT_TIMESTAMP

      foreign_key [:spotify_user_id], :spotify_users, on_delete: :cascade
      foreign_key [:playlist_id], :playlists, on_delete: :cascade

      primary_key [:spotify_user_id, :playlist_id]
    end

    alter_table :playlists do
      drop_column :spotify_user_id
      drop_column :owner
    end
  end
end
