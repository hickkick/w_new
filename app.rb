require 'httparty'
require 'json'
require 'base64'
require 'dotenv/load'

def fetch_access_token(client_id, client_secret)
  encoded = Base64.strict_encode64("#{client_id}:#{client_secret}")

  response = HTTParty.post(
    "https://accounts.spotify.com/api/token",
    headers: {
      "Authorization" => "Basic #{encoded}",
      "Content-Type" => "application/x-www-form-urlencoded"
    },
    body: {
      "grant_type" => "client_credentials"
    }
  )

  json = JSON.parse(response.body)
  json['access_token']
end

client_id = ENV['SPOTIFY_CLIENT_ID']
client_secret = ENV['SPOTIFY_CLIENT_SECRET']

abort("Missing SPOTIFY_CLIENT_ID") unless client_id
abort("Missing SPOTIFY_CLIENT_SECRET") unless client_secret

access_token = fetch_access_token(client_id, client_secret)
puts "Access token: #{access_token}"
