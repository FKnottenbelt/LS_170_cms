require_relative '../helpers/test_helper'

class UnitTest < CapybaraTestCase
  include Helpers

  def test_unit_test_have_run
    puts "Unit tests running"
  end

end

