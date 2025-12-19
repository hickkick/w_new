class FetchSpotifyPlaylistSnapshot
  def initialize(spotify_client:, playlist:, spotify_snapshot_id:)
    @spotify_client = spotify_client
    @playlist = playlist
    @spotify_snapshot_id = spotify_snapshot_id
  end

  def call
    return :unchanged if snapshot_already_fetched?

    tracks_data = @spotify_client.get_playlist_tracks(
      @playlist.playlist_id
    )

    snapshot = PlaylistSnapshot.create(
      playlist_id: @playlist.id,
      spotify_snapshot_id: @spotify_snapshot_id,
      snapshot_time: Time.now,
    )

    tracks_data.each_with_index do |item, index|
      track_data = item["track"]
      next unless track_data

      track = Track.find_or_create(
        spotify_track_id: track_data["id"],
      )

      track.update(
        name: track_data["name"],
        artists: extract_artists(track_data),
        album: track_data["album"]["name"],
        album_cover_url: track_data.dig("album", "images", 1, "url") || "/default_album_cover.jpg",
        duration_ms: track_data["duration_ms"],
        play_url: track_data.dig("external_urls", "spotify") || "#",
      )

      existing = PlaylistSnapshotTrack.first(
        snapshot_id: snapshot.id,
        track_id: track.id,
        position: index,
      )

      unless existing
        PlaylistSnapshotTrack.create(
          snapshot_id: snapshot.id,
          track_id: track.id,
          added_at: item["added_at"],
          position: index,
        )
      end
    end

    snapshot
  end

  private

  def snapshot_already_fetched?
    last_snapshot = @playlist
      .playlist_snapshots_dataset
      .order(:snapshot_time)
      .last

    return false unless last_snapshot

    last_snapshot.spotify_snapshot_id == @spotify_snapshot_id
  end

  def extract_artists(track_data)
    track_data["artists"].map { |a| a["name"] }.join(", ")
  end
end
