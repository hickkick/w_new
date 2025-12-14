require_relative "./playlist_snapshot_diff"

class UserPlaylistChanges
  def initialize(user, playlist)
    @user = user
    @playlist = playlist
  end

  def diff
    PlaylistSnapshotDiff.new(last_seen_snapshot, current_snapshot)
  end

  def added
    diff.added
  end

  def removed
    diff.removed
  end

  def current_snapshot
    @current_snapshot ||= @playlist
      .playlist_snapshots_dataset
      .order(:snapshot_time)
      .last
  end

  def last_seen_snapshot
    return nil unless seen_record

    seen_record.last_seen_snapshot
  end

  private

  def seen_record
    @seen_record ||= UserSeenChange.first(
      user_id: @user.id,
      playlist_id: @playlist.id,
    )
  end
end
