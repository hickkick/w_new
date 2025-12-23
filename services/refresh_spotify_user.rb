class RefreshSpotifyUser
  def initialize(spotify_user_id:, client:, user:)
    @spotify_user_id = spotify_user_id
    @client = client
    @user = user
  end

  def call
    spotify_user = SpotifyUser.find_or_create(
      spotify_user_id: @spotify_user_id,
    )

    FetchSpotifyUserProfile.new(
      spotify_client: @client,
      spotify_user: spotify_user,
    ).call

    playlists = FetchSpotifyUserPlaylists.new(
      spotify_client: @client,
      spotify_user: spotify_user,
    ).call

    pending_change = []

    playlists.each do |playlist|
      link = SpotifyUserPlaylist.first(
        spotify_user_id: spotify_user.id,
        playlist_id: playlist.id,
      )

      state = UserPlaylistSnapshotState.first(
        user_id: @user.id,
        playlist_id: playlist.id,
      )

      from_snapshot_id = state ? state.playlist_snapshot_id : nil

      snapshot = FetchSpotifyPlaylistSnapshot.new(
        spotify_client: @client,
        playlist: playlist,
        spotify_snapshot_id: link.spotify_snapshot_id,
      ).call

      next if snapshot == :unchanged

      if from_snapshot_id
        pending_change << {
          playlist_id: playlist.id,
          from_snapshot: from_snapshot_id,
          to_snapshot: snapshot.id,
        }
      end
    end

    if pending_change.any?
      Instrumentation.measure("Watch Changes creates in db") do
        watch_change = WatchChange.create(
          user_id: @user.id,
          spotify_user_id: spotify_user.id,
        )

        pending_change.each do |chg|
          watch_change_playlists = WatchChangePlaylist.create(
            watch_change_id: watch_change.id,
            playlist_id: chg[:playlist_id],
            from_snapshot_id: chg[:from_snapshot],
            to_snapshot_id: chg[:to_snapshot],
          )
        end
      end
    end

    # spotify_user
  end
end
