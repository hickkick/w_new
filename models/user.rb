class User < Sequel::Model
  one_to_many :user_playlist_snapsot_states
end
