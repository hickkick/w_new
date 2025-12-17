class User < Sequel::Model
  # one_to_many :user_playlist_trackings

  # many_to_many :spotify_users,
  #              join_table: :user_playlist_tracking

  # one_to_many :user_seen_changes

  one_to_many :user_playlist_snapsot_states
end
