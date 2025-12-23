module Routes
  module Watch
    def self.registered(app)
      app.post("/watch") do
        link = params[:link]&.strip

        if link.nil? || link.empty?
          @error = t("errors.empty_link")
          return erb :index
        end

        spotify_user_id = extract_spotify_user_id(link)

        unless spotify_user_id
          @error = t("errors.invalid_spotify_link")
          return erb :index
        end

        begin
          client = SpotifyClient.new(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"])

          RefreshSpotifyUser.new(
            spotify_user_id: spotify_user_id,
            client: client,
            user: @current_user,
          ).call

          redirect "/watch/#{spotify_user_id}"
        rescue SpotifyClient::NotFoundError
          @error = t("errors.user_not_found", username: spotify_user_id)
          erb :index
        rescue => e
          @error = t("errors.unexpected_error")
          erb :index
        end
      end

      app.post("/watch/:id") do
        client = SpotifyClient.new(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"])
        spotify_user_id = params[:id]

        RefreshSpotifyUser.new(
          spotify_user_id: spotify_user_id,
          client: client,
          user: @current_user,
        ).call

        redirect "/watch/#{spotify_user_id}"
      end

      app.get("/watch/:id") do
        spotify_user = SpotifyUser.first(spotify_user_id: params[:id])
        halt 404 unless spotify_user

        page = WatchPageResolver.new(
          spotify_user: spotify_user,
          current_user: @current_user,
          change_id: params[:change],
        ).call

        erb :list, locals: {
                     spotify_user_id: spotify_user.spotify_user_id,
                     user_display_name: spotify_user.display_name,
                     user_avatar: spotify_user.avatar_img_url,
                     stats: SpotifyUserStats.new(spotify_user),
                     results: page[:results],
                     first_time_per_user: page[:first_time_per_user],
                     navigation: page[:navigation],
                   }
      end
    end
  end
end
