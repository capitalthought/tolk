ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../lib/tolk")
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails/test_help'

require 'capybara/rails'

class Hash
  undef :ya2yaml
end

require 'mocha'
class ActiveSupport::TestCase
  include Mocha::API
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  fixtures :all

  self.fixture_class_names = {:tolk_locales => 'Tolk::Locale', :tolk_phrases => 'Tolk::Phrase', :tolk_translations => 'Tolk::Translation'}
  
  def setup
    mocha_setup
  end
  
  def teardown
    begin
      mocha_verify
    ensure
      mocha_teardown
    end
  end
end

class ActionController::IntegrationTest
  def setup
    @session = Capybara::Session.new(:rack_test, Rails.application)
  end
  
  def teardown
  end
  
  def assert_contain content
    assert @session.has_content?(content)
  end
end