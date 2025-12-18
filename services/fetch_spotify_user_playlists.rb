class FetchSpotifyUserPlaylists
  def initialize(spotify_client:, spotify_user:)
    @spotify_client = spotify_client
    @spotify_user = spotify_user
  end

  def call
    playlists_data = @spotify_client.get_user_playlists(
      @spotify_user.spotify_user_id
    )

    playlists_data.map do |p|
      playlist = Playlist.find_or_create(
        playlist_id: p["id"],
      )

      sup = SpotifyUserPlaylist.find_or_create(
        spotify_user_id: @spotify_user.id,
        playlist_id: playlist.id,
      )

      sup.update(
        owner: p.dig("owner", "id") == @spotify_user.spotify_user_id,
        spotify_snapshot_id: p["snapshot_id"],
      )

      playlist.update(
        name: p["name"],
        description: p["description"],
        image_url: p.dig("images", 0, "url"),
      )

      playlist
    end
  end
end
