class WatchPageResolver
  def initialize(spotify_user:, current_user:, change_id:)
    @spotify_user = spotify_user
    @current_user = current_user
    @change_id = change_id
  end

  def call
    if @change_id
      WatchChangePageQuery.new(
        spotify_user: @spotify_user,
        current_user: @current_user,
        change_id: @change_id,
      ).call
    else
      result = WatchPageQuery.new(
        spotify_user: @spotify_user,
        current_user: @current_user,
      ).call

      UpdateUserPlaylistSnapshotState.new(
        user: @current_user,
        spotify_user: @spotify_user,
        playlists: @spotify_user.playlists,
      ).call

      result
    end
  end
end
