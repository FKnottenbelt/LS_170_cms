ENV["RACK_ENV"] = "test"

require 'minitest/reporters'
Minitest::Reporters.use!
require 'minitest/autorun'
require 'capybara/minitest'

require_relative '../../app.rb'

class CapybaraTestCase < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  Capybara.app = Sinatra::Application

  Capybara.save_path = './tmp/'

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
