class TrackPresenter
  def initialize(playlist_snapshot_track)
    @pst = playlist_snapshot_track
    @track = playlist_snapshot_track.track
  end

  def name
    @track.name
  end

  def artists
    @track.artists
  end

  def album_cover
    @track.album_cover_url || "/images/default_cover.jpg"
  end

  def added_at_formatted
    return "" unless @pst.added_at
    @pst.added_at.strftime("%d.%m.%Y")
  end
end
