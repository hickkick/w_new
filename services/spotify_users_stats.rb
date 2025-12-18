class SpotifyUserStats
  def initialize(spotify_user)
    @spotify_user = spotify_user
  end

  def playlists
    @playlists ||= @spotify_user.playlists_dataset.all
  end

  def owned_playlists
    owned_pl.count
  end

  def owned_pl
    @owned_playlists ||= @spotify_user
      .spotify_user_playlists_dataset
      .where(owner: true)
      .map(&:playlist)
  end

  def current_owned_snapshots
    @current_owned_snapshots ||= owned_pl.map do |playlist|
      playlist
        .playlist_snapshots_dataset
        .order(:snapshot_time)
        .last
    end.compact
  end

  def owned_snapshot_tracks
    @owned_snapshot_tracks ||= current_owned_snapshots.flat_map do |snapshot|
      snapshot
        .playlist_snapshot_tracks_dataset
        .all
    end
  end

  def current_snapshots
    @current_snapshots ||= playlists.map do |playlist|
      playlist
        .playlist_snapshots_dataset
        .order(:snapshot_time)
        .last
    end.compact
  end

  def snapshot_tracks
    @snapshot_tracks ||= current_snapshots.flat_map do |snapshot|
      snapshot
        .playlist_snapshot_tracks_dataset
        .all
    end
  end

  def total_playlists
    playlists.count
  end

  def total_tracks
    snapshot_tracks.size
  end

  def latest_snapshot_track
    owned_snapshot_tracks
      .select(&:added_at)
      .max_by(&:added_at)
  end

  def latest_track_name
    latest_snapshot_track&.track&.name
  end

  def latest_track_artist
    latest_snapshot_track&.track&.artists
  end

  def latest_track_date
    latest_snapshot_track&.added_at&.strftime("%d.%m.%Y")
  end
end
