class WatchPageQuery
  def initialize(spotify_user:, current_user:)
    @spotify_user = spotify_user
    @current_user = current_user
  end

  def call
    Instrumentation.measure("Watch Page Query 'get /watch/:id'") do
      playlists = @spotify_user.playlists

      results = playlists.map do |playlist|
        current_snapshot = playlist
          .playlist_snapshots_dataset
          .order(Sequel.desc(:snapshot_time))
          .first

        state = UserPlaylistSnapshotState.first(
          user_id: @current_user.id,
          playlist_id: playlist.id,
        )

        PlaylistPresenter.new(
          playlist: playlist,
          previous_snapshot: state&.playlist_snapshot,
          current_snapshot: current_snapshot,
        )
      end

      {
        results: results,
        first_time_per_user: first_time_per_user?,
      }
    end
  end

  private

  def first_time_per_user?
    UserPlaylistSnapshotState.where(
      user_id: @current_user.id,
      spotify_user_id: @spotify_user.id,
    ).empty?
  end
end
