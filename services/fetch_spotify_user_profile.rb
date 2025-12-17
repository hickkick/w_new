require "time"

class FetchSpotifyUserProfile
  def initialize(spotify_client:, spotify_user:)
    @client = spotify_client
    @spotify_user = spotify_user
  end

  def call
    data = @client.fetch_user_profile(@spotify_user.spotify_user_id)

    @spotify_user.update(
      display_name: data["display_name"],
      avatar_img_url: data.dig("images", 0, "url"),
      last_fetched_at: Time.now,
    )
  end
end
