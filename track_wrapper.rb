# frozen_string_literal: true

class TrackWrapper
  attr_reader :raw

  def initialize(raw)
    @raw = raw
  end

  def name
    raw.dig("track", "name") || "—"
  end

  def artists
    raw.dig("track", "artists")&.map { |a| a["name"] }&.join(", ") || "Невідомо"
  end

  def album_cover
    raw.dig("track", "album", "images", 1, "url") || "/default.jpg"
  end

  def added_at
    Time.parse(raw["added_at"])
  rescue
    nil
  end

  def added_at_formatted
    added_at&.strftime("%d.%m.%Y %H:%M") || "-"
  end

  def play_url
    raw.dig("track", "external_urls", "spotify") || "#"
  end
end
