class WatchPageResolver
  def initialize(spotify_user:, current_user:, change_id:)
    @spotify_user = spotify_user
    @current_user = current_user
    @change_id = change_id
  end

  def call
    if @change_id
      page = WatchChangePageQuery.new(
        spotify_user: @spotify_user,
        current_user: @current_user,
        change_id: @change_id,
      ).call
    else
      page = WatchPageQuery.new(
        spotify_user: @spotify_user,
        current_user: @current_user,
      ).call

      UpdateUserPlaylistSnapshotState.new(
        user: @current_user,
        spotify_user: @spotify_user,
        playlists: @spotify_user.playlists,
      ).call
    end
    # LOGGER.debug("current change id: #{@change_id.class}")
    navigation = ChangeNavigationResolver.new(
      spotify_user: @spotify_user,
      user: @current_user,
      current_change_id: @change_id,
    ).call

    page.merge(navigation: navigation)
  end
end
