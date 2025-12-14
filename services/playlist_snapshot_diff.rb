class PlaylistSnapshotDiff
  def initialize(old_snapshot, new_snapshot)
    @old = old_snapshot
    @new = new_snapshot
  end

  def added
    return all_new_tracks if @old.nil?

    Track.where(id: added_ids).all
  end

  def removed
    return [] if @old.nil?

    Track.where(id: removed_ids).all
  end

  private

  def all_new_tracks
    @new.tracks_dataset.all
  end

  def added_ids
    @new.tracks_dataset
      .select(:id)
      .exclude(id: @old.tracks_dataset.select(:id))
  end

  def removed_ids
    @old.tracks_dataset
      .select(:id)
      .exclude(id: @new.tracks_dataset.select(:id))
  end
end
