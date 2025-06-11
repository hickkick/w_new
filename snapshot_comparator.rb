class SnapshotComparator
  def self.compare(old_tracks, new_tracks)
    old_tracks ||= []
    new_tracks ||= []

    added = new_tracks.reject do |new_track|
      old_tracks.any? { |old| track_id(old) == track_id(new_track) }
    end

    removed = old_tracks.reject do |old_track|
      new_tracks.any? { |new| track_id(old_track) == track_id(new) }
    end

    { added: added, removed: removed }
  end

  def self.track_id(track_wrapper)
    track = track_wrapper["track"] || track_wrapper
    track["id"]
  end
end
