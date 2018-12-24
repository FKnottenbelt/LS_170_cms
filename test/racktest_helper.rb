ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require_relative "../cms.rb"

class RackTestCase < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
end