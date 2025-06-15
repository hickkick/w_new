class PlaylistStatistics
  def self.compute(playlists, user_id)
    owned = playlists.select { |pl| pl.owner_id == user_id }

    all_owned_tracks = owned.flat_map(&:tracks).compact

    {
      total_playlists: playlists.size,
      owned_playlists: owned.size,
      total_tracks: all_owned_tracks.size,
      latest_added_track: all_owned_tracks
        .select { |t| t.respond_to?(:added_at) && t.added_at } # додатковий захист
        .max_by(&:added_at)
    }
  end
end
