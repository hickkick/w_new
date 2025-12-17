# class SpotifyUserPlaylist < Sequel::Model
#   set_primary_key [:spotify_user_id, :playlist_id]
#   unrestrict_primary_key

#   many_to_one :spotify_user
#   many_to_one :playlist
# end
class SpotifyUserPlaylist < Sequel::Model
  set_primary_key [:spotify_user_id, :playlist_id]
  # unrestrict_primary_key
  many_to_one :spotify_user
  many_to_one :playlist
end
