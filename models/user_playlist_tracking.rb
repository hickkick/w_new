class UserPlaylistTracking < Sequel::Model(:user_playlist_tracking)
  many_to_one :user
  many_to_one :spotify_user
end
