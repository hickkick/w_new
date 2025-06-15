# frozen_string_literal: true
require 'time'

class TrackWrapper
  attr_reader :raw

  def initialize(raw)
    @raw = raw
  end

  def track_data
    raw["track"] || raw
  end

  def id
    track_data["id"]
  end

  def name
    track_data["name"] || "—"
  end

  def artists
    track_data["artists"]&.map { |a| a["name"] }&.join(", ") || "Невідомо"
  end

  def album_cover
    track_data.dig("album", "images", 1, "url") || "/default.jpg"
  end

  def added_at
    Time.parse(raw["added_at"].to_s)
  rescue ArgumentError, TypeError
    nil
  end

  def added_at_formatted
    added_at&.strftime("%d.%m.%Y %H:%M") || "-"
  end

  def play_url
    track_data.dig("external_urls", "spotify") || "#"
  end

  def to_h
    {
      id: id,
      name: name,
      artists: artists,
      album_cover: album_cover,
      added_at: added_at_formatted,
      play_url: play_url
    }
  end
end
