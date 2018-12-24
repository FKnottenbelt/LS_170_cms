require_relative './racktest_helper'
require 'pry'
class CmsTest < RackTestCase

  def test_rake_test_have_run
    puts "Rake tests running"
  end

  def test_home_page
    get "/"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes(last_response.body, "about.txt")
    assert_includes(last_response.body, "changes.txt")
    assert_includes(last_response.body, "history.txt")
  end

  def test_file_page
    get "/about.txt"
    assert_equal 200, last_response.status
    assert_equal "text/plain", last_response["Content-Type"]
    assert_includes(last_response.body, "Ruby was influenced by Perl")
  end

  def test_file_page_gives_error_when_file_does_not_exist
    get "/nonexisting.txt"
    assert_equal 302, last_response.status

    get last_response["Location"]  # follow redirect
    assert_equal 200, last_response.status
    assert_includes last_response.body, "nonexisting.txt does not exist"

    get "/"
    refute_includes(last_response.body, "nonexisting.txt does not exist")
  end
end
