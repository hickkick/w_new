class WatchChangePageQuery
  class NotFound < StandardError; end

  def initialize(spotify_user:, current_user:, change_id:)
    @spotify_user = spotify_user
    @current_user = current_user
    @change_id = change_id
  end

  def call
    Instrumentation.measure("Watch CHANGE page query: ") do
      change = WatchChange.first(
        id: @change_id,
        user_id: @current_user.id,
        spotify_user_id: @spotify_user.id,
      )

      raise NotFound unless change

      results = change.watch_change_playlists.map do |wcp|
        PlaylistPresenter.new(
          playlist: wcp.playlist,
          previous_snapshot: wcp.from_snapshot,
          current_snapshot: wcp.to_snapshot,
        )
      end

      {
        results: results,
        first_time_per_user: false,
      }
    end
  end
end
