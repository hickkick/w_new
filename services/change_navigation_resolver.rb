class ChangeNavigationResolver
  def initialize(user:, spotify_user:, current_change_id:)
    @user = user
    @spotify_user = spotify_user
    @current_change_id = current_change_id
  end

  def call
    changes = WatchChange
      .where(user_id: @user.id, spotify_user_id: @spotify_user.id)
      .order(:id)
      .all

    return empty_navigation if changes.empty?

    # DEFAULT MODE
    if @current_change_id.nil?
      return {
               prev_change_id: changes.last.id,
               next_change_id: nil,
             }
    end

    # CHANGE MODE
    current_index = changes.index { |c| c.id == @current_change_id.to_i }
    return empty_navigation unless current_index

    prev_change = current_index > 0 ? changes[current_index - 1] : nil
    next_change = changes[current_index + 1]

    {
      prev_change_id: prev_change&.id,
      next_change_id: next_change ? next_change.id : :default,
    }
  end

  private

  def empty_navigation
    {
      prev_change_id: nil,
      next_change_id: nil,
    }
  end
end
