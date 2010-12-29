module Tolk
  module Import
    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods

      def import_secondary_locales
        locales = Dir.glob("#{self.locales_config_path}/**/#{self.primary_locale_name}.yml")
        locales = locales.reject {|l| ['.', '..'].include?(l) || !l.ends_with?('.yml') }.map {|x| x.split('.').first }.uniq - [Tolk::Locale.primary_locale.name]

        locales.each {|l| import_locale(l) }
      end

      def import_locale(locale_name)
        locale = Tolk::Locale.find_or_create_by_name(locale_name)
        data = locale.read_locale_files

        phrases = Tolk::Phrase.all
        count = 0

        data.each do |key, value|
          phrase = phrases.detect {|p| p.key == key}

          if phrase
            translation = locale.translations.new(:text => value, :phrase => phrase)
            count = count + 1 if translation.save
          else
            puts "[ERROR] Key '#{key}' was found in #{locale_name}.yml but #{Tolk::Locale.primary_language_name} translation is missing"
          end
        end

        puts "[INFO] Imported #{count} keys from #{locale_name}.yml"
      end

    end

    def read_locale_files
      locale_files = Dir.glob("#{self.locales_config_path}/**/#{self.name}.yml")
      translations = {}
      locale_files.each do |locale_file|
        translations.merge(self.class.flat_hash(YAML::load(IO.read(locale_file))[self.name]))
      end
      translations
    end

  end
end
