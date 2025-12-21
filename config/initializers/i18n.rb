require "i18n"

I18n.load_path += Dir[File.join(File.dirname(__FILE__), "../../locales", "*.yml")]
I18n.available_locales = [:en, :uk]
I18n.default_locale = :en
I18n.backend.load_translations
