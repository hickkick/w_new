class WatchChangePageQuery
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

      halt_not_found unless change

      results = change.watch_change_playlists.map do |wcp|
        PlaylistPresenter.new(
          playlist: wcp.playlist,
          previous_snapshot: wcp.from_snapshot,
          current_snapshot: wcp.to_snapshot,
        )
      end

      prev_change = WatchChange
        .where(user_id: @current_user.id, spotify_user_id: @spotify_user.id)
        .where { id < change.id }
        .order(Sequel.desc(:id))
        .first

      next_change = WatchChange
        .where(user_id: @current_user.id, spotify_user_id: @spotify_user.id)
        .where { id > change.id }
        .order(:id)
        .first

      {
        results: results,
        first_time_per_user: false,
        navigation: {
          current_change_id: change.id,
          prev_change_id: prev_change&.id,
          next_change_id: next_change&.id,
        },
      }
    end
  end
end
