class PlaylistPresenter
  def initialize(playlist:, previous_snapshot:, current_snapshot:)
    @playlist = playlist
    @previous_snapshot = previous_snapshot
    @current_snapshot = current_snapshot
  end

  attr_reader :playlist

  def name
    playlist.name
  end

  def image_url
    playlist.image_url
  end

  def tracks
    current_snapshot_tracks.map do |pst|
      TrackPresenter.new(pst)
    end
  end

  def added
    return tracks if @previous_snapshot.nil?

    added_ids = current_ids - previous_ids
    wrap_tracks(added_ids)
  end

  def removed
    return [] if @previous_snapshot.nil?

    removed_ids = previous_ids - current_ids
    wrap_tracks(removed_ids, from: @previous_snapshot)
  end

  private

  def current_snapshot_tracks
    @current_snapshot_tracks ||= @current_snapshot
      .playlist_snapshot_tracks_dataset
      .order(:position)
      .all
  end

  def previous_snapshot_tracks
    return [] unless @previous_snapshot

    @previous_snapshot_tracks ||= @previous_snapshot
      .playlist_snapshot_tracks_dataset
      .all
  end

  def current_ids
    current_snapshot_tracks.map(&:track_id)
  end

  def previous_ids
    previous_snapshot_tracks.map(&:track_id)
  end

  def wrap_tracks(ids, from: @current_snapshot)
    from.playlist_snapshot_tracks_dataset
        .where(track_id: ids)
        .order(:position)
        .map { |pst| TrackPresenter.new(pst) }
  end
end
