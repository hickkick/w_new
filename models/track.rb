class Track < Sequel::Model
  one_to_many :playlist_snapshot_tracks
end
