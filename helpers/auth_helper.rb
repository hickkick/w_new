require "securerandom"

module AuthHelper
  def current_user
    @current_user ||= begin
        uuid = get_or_create_user_uuid
        User.first(uuid: uuid) || User.create(uuid: uuid)
      end
  end

  private

  def get_or_create_user_uuid
    return session[:user_uuid] if session[:user_uuid]

    if (old_uuid = request.cookies["app_user_id"])
      session[:user_uuid] = old_uuid
      response.delete_cookie("app_user_id", path: "/")
      return old_uuid
    end

    uuid = SecureRandom.uuid
    session[:user_uuid] = uuid
    uuid
  end
end
