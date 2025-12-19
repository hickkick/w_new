class UserStateComparator
  def initialize(playlist:, user_state:)
    @playlist = playlist
    @user_state = user_state
  end

  def call
    current = playlist
      .playlist_snapshots_dataset
      .order(Sequel.desc(:snapshot_time))
      .first

    return nil unless current

    previous = user_state&.playlist_snapshot

    {
      current_snapshot: current,
      previous_snapshot: previous,
    }
  end
end
