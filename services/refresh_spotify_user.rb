class RefreshSpotifyUser
  def initialize(spotify_user_id:, client:)
    @spotify_user_id = spotify_user_id
    @client = client
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

    playlists.each do |playlist|
      link = SpotifyUserPlaylist.first(
        spotify_user_id: spotify_user.id,
        playlist_id: playlist.id,
      )

      snapshot = FetchSpotifyPlaylistSnapshot.new(
        spotify_client: @client,
        playlist: playlist,
        spotify_snapshot_id: link.spotify_snapshot_id,
      ).call

      next if snapshot == :unchanged
    end

    # spotify_user
  end
end
