module LocaleHelper
  def set_locale
    I18n.locale = session[:locale] || I18n.default_locale
  end
end
