class StatsWrapper
  attr_reader :total_playlists, :owned_playlists, :total_tracks, :latest_track
  
  def initialize(data)
    @total_playlists = data[:total_playlists]
    @owned_playlists = data[:owned_playlists]
    @total_tracks    = data[:total_tracks]
    @latest_track    = data[:latest_added_track]
  end
  
  def latest_track_name
    latest_track&.name || "—"
  end
  
  def latest_track_artist
    latest_track&.artists || "Невідомо"
  end
  
  def latest_track_date
    latest_track&.added_at&.strftime("%d.%m.%y") || "-"
  end
end
  