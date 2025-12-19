module SpotifyLinkHelper
  # Простий regex - чи це взагалі Spotify user link
  SPOTIFY_USER_LINK_REGEX = %r{\Ahttps://open\.spotify\.com/user/([a-z0-9]+)(\?.*?)?\z}ix

  def extract_spotify_user_id(link)
    return nil if link.nil? || link.strip.empty?
    match = link.strip.match(SPOTIFY_USER_LINK_REGEX)
    match ? match[1] : nil
  end
end
