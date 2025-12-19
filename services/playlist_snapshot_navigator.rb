class PlaylistSnapshotNavigator
  def initialize(playlist:, requested_snapshot_id:)
    @playlist = playlist
    @requested_snapshot_id = requested_snapshot_id
  end

  def call
    current = playlist
      .playlist_snapshots_dataset
      .where(id: requested_snapshot_id)
      .first

    return nil unless current

    previous = playlist
      .playlist_snapshots_dataset
      .where { snapshot_time < current.snapshot_time }
      .order(Sequel.desc(:snapshot_time))
      .first

    {
      current_snapshot: current,
      previous_snapshot: previous,
    }
  end

  private

  attr_reader :playlist, :requested_snapshot_id
end
