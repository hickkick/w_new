module Routes
  module Base
    def self.registered(app)
      app.get("/") do
        erb :index
      end

      app.get("/set_lang") do
        lang = params[:lang].to_sym

        if I18n.available_locales.include?(lang)
          session[:locale] = lang
        end

        redirect params[:redirect_to] || back || "/"
      end
    end
  end
end
