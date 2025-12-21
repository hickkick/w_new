require "i18n"

module TranslateHelper
  def t(key, **opts)
    I18n.t(key, **opts)
  end
end
