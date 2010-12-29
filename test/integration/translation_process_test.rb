require 'test_helper'

class TranslationProcessTest < ActionController::IntegrationTest
  setup :setup_locales

  def test_adding_locale
    assert_difference('Tolk::Locale.count') { add_locale 'German' }
  end

  def test_adding_missing_translations_and_updating_translations
    Tolk::Locale::MAPPING['xx'] = "Pirate"
    
    locale = add_locale("Pirate")
    assert locale.translations.empty?

    # Adding a new translation
    pirate_url = tolk_locale_url(locale)
    @session.visit pirate_url
    @session.fill_in 'translations[][text]', :with => "Dead men don't bite"
    @session.click_button 'Save changes'

    assert_equal @session.current_url, pirate_url
    assert_equal 1, locale.translations.count

    # Updating the translation added above
    @session.click_link 'See completed translations'
    assert_contain "Dead men don't bite"

    @session.fill_in 'translations[][text]', :with => "Arrrr!"
    @session.click_button 'Save changes'

    assert_equal @session.current_url, all_tolk_locale_url(locale)
    assert_equal 1, locale.translations.count
    assert_equal 'Arrrr!', locale.translations(true).first.text
  end

  private
  
  def tolk_root_path
    "/tolk"
  end

  def add_locale(name)
    @session.visit tolk_root_path
    @session.select name
    @session.click_button 'Add'

    Tolk::Locale.find_by_name!(Tolk::Locale::MAPPING.key(name))
  end

  def setup_locales
    Tolk::Locale.delete_all
    Tolk::Translation.delete_all
    Tolk::Phrase.delete_all

    Tolk::Locale.locales_config_path = File.join(Rails.root, "test/locales/sync/")

    I18n.backend.reload!
    I18n.load_path = [Tolk::Locale.locales_config_path + 'en.yml']
    I18n.backend.send :init_translations

    Tolk::Locale.primary_locale(true)

    Tolk::Locale.sync!
  end
end
