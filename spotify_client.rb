require 'httparty'
require 'json'
require 'base64'

class SpotifyClient
  TOKEN_URL = "https://accounts.spotify.com/api/token"
  API_BASE = "https://api.spotify.com/v1"
  CACHE_FILE = "token_cache.json"

  def initialize(client_id, client_secret)
    @client_id = client_id
    @client_secret = client_secret
    @access_token = load_token
  end

  def extract_user_id(profile_url)
    match = profile_url.match(%r{user/([^/?]+)})
    match ? match[1] : nil
  end

  def get_user_playlists(user_id)
    url = "#{API_BASE}/users/#{user_id}/playlists"
    make_request(url)
  end

  def get_playlist_tracks(playlist_id)
    url = "#{API_BASE}/playlists/#{playlist_id}/tracks"
    make_request(url)
  end

  private

  def make_request(url)
    refresh_token_if_needed
    response = HTTParty.get(url, headers: {
      "Authorization" => "Bearer #{@access_token}"
    })
    JSON.parse(response.body)
  end

  def load_token
    if File.exist?(CACHE_FILE)
      cache = JSON.parse(File.read(CACHE_FILE))
      if Time.now.to_i < cache["expires_at"]
        return cache["access_token"]
      end
    end
    fetch_and_cache_token
  end

  def refresh_token_if_needed
    load_token if @access_token.nil?
  end

  def fetch_and_cache_token
    credentials = Base64.strict_encode64("#{@client_id}:#{@client_secret}")
    response = HTTParty.post(TOKEN_URL,
      headers: {
        "Authorization" => "Basic #{credentials}",
        "Content-Type" => "application/x-www-form-urlencoded"
      },
      body: {
        "grant_type" => "client_credentials"
      }
    )

    data = JSON.parse(response.body)
    @access_token = data["access_token"]
    expires_in = data["expires_in"] # usually 3600 (1 hour)

    File.write(CACHE_FILE, JSON.pretty_generate({
      access_token: @access_token,
      expires_at: Time.now.to_i + expires_in
    }), perm: 0600)

    @access_token
  end
end
