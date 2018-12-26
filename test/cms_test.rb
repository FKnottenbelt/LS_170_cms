require_relative './racktest_helper'

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

  def test_file_page_file_renders_as_plain_tekst
    get "/about.txt"
    assert_equal 200, last_response.status
    assert_equal "text/plain;charset=utf-8", last_response["Content-Type"]
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

  def test_markdown_file_renders_as_html
    get "/requirement6.md"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<em>Gemfile</em>"
  end

  def test_edit_text
    get "/test.txt/edit"
    assert_equal 200, last_response.status
    assert_includes last_response.body, "Edit content of test.txt"
    assert_includes last_response.body, "Documents can be edited now"
  end

  def test_update_text
    post "/test.txt/edit", edit_box: "Did it!"
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "test.txt has been updated"
    assert_equal 200, last_response.status

    get "/test.txt"
    assert_equal 200, last_response.status
    assert_includes last_response.body, "Did it!"
  end
end
