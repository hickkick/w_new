class PlaylistWatcher
  def initialize(client)
    @client = client
  end

  def watch_user_playlists(user_id)
    playlists = @client.get_user_playlists(user_id)
    # if playlists["items"]
    #   playlists["items"].each_with_index do |pl, i|
    #     puts "[#{i + 1}] #{pl["name"]} (#{pl["tracks"]["total"]} треків)"
    #   end
    # else
    #   puts "Не вдалося отримати плейлісти."
    # end
    playlists["items"] || []
  end

  def watch_playlist_tracks(playlist_id)
    tracks = @client.get_playlist_tracks(playlist_id)
    return [] unless tracks["items"]

    # tracks["items"].each_with_index do |track, i|
    #   track_info = track["track"]
    #   puts "[#{i + 1}] #{track_info["name"]} - #{track_info["artists"].map { |a| a["name"] }.join(", ")}"
    # end

    tracks["items"] 
  end
end
