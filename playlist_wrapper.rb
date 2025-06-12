# models/playlist_wrapper.rb
class PlaylistWrapper
  attr_reader :id, :name, :total, :added, :removed, :tracks

  def initialize(data)
    @id = data[:id]
    @name = data[:name]
    @total = data[:total] || 0

    @added = wrap_tracks(data[:added] || [])
    @removed = wrap_tracks(data[:removed] || [])
    @tracks = wrap_tracks(data[:tracks] || [])
  end

  def has_added?
    @added.any?
  end

  def has_removed?
    @removed.any?
  end

  private

  def wrap_tracks(raw)
    raw.map do |t|
      TrackWrapper.new(t)
    end
  end
end
