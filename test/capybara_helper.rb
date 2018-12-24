ENV["RACK_ENV"] = "test"

require 'minitest/reporters'
Minitest::Reporters.use!
require 'minitest/autorun'
require 'capybara/minitest'

require_relative '../cms.rb'

class CapybaraTestCase < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  Capybara.app = Sinatra::Application

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end