class UpdateUserPlaylistSnapshotState
  def initialize(user:, spotify_user:, playlists:)
    @user = user
    @spotify_user = spotify_user
    @playlists = playlists
  end

  def call
    @playlists.each do |playlist|
      current_snapshot = playlist
        .playlist_snapshots_dataset
        .order(Sequel.desc(:snapshot_time))
        .first

      next unless current_snapshot

      state = UserPlaylistSnapshotState.first(
        user_id: @user.id,
        spotify_user_id: @spotify_user.id,
        playlist_id: playlist.id,
      )

      if state
        state.update(
          playlist_snapshot_id: current_snapshot.id,
          updated_at: Time.now,
        )
      else
        UserPlaylistSnapshotState.create(
          user_id: @user.id,
          spotify_user_id: @spotify_user.id,
          playlist_id: playlist.id,
          playlist_snapshot_id: current_snapshot.id,
        )
      end
    end
  end
end
