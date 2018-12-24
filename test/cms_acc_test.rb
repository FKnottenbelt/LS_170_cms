require_relative './capybara_helper'

class CmsAcceptTest < CapybaraTestCase

  def test_acc_test_have_run
    puts "Acc tests running"
  end

  def test_clicking_file_opens_file
    # If I am at the home page
    visit '/'
    # and I click on a file
    click_link "about.txt"
    # I will go to a new page /filename
    assert_current_path '/about.txt'
    # where I see the contents of my file
    assert_includes(page.html, "Ruby was influenced by Perl")
  end
end