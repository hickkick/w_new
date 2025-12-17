# Sequel.migration do
#   change do
#     create_table :tracks do
#       primary_key :id
#       String :spotify_track_id, null: false
#       String :name
#       String :artists
#       String :album
#       String :album_cover_url
#       String :play_url
#       Integer :duration_ms

#       DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP

#       index :spotify_track_id, unique: true
#     end
#   end
# end
Sequel.migration do
  change do
    create_table :tracks do
      primary_key :id
      String :spotify_track_id, null: false, unique: true

      String :name
      String :artists
      String :album
      String :album_cover_url
      String :play_url
      Integer :duration_ms

      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
