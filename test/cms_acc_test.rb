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

  def test_editing_a_file
    # If I am at the home page
    visit '/'
    # I should see a link for test.txt
    page.has_link? ('test.txt')
    # technical interlude to find the right edit link next to our text
    counter = 0
    save_counter = 0
    loop do
      if page.all('a')[counter].text == 'test.txt'
        save_counter = counter + 1
        break
      end
      counter += 1
    end
    # and I click on the edit link next to test.txt
    page.all('a')[save_counter].click
    # I should be on the edit page
    assert_current_path '/test.txt/edit'
    # if I edit the text
    fill_in 'edit_box', with: 'Edited by acc-test'
    # and click the submit button
    click_button 'Save changes'
    # I will be redirected to the home page
    assert_current_path '/'
    # I will see a succes message
    assert_content("test.txt has been updated")
    # If I once again visit the edit page
    page.all('a')[save_counter].click
    # I should see my edited text
    assert_content 'Edited by acc-test'
    # (reset text)
    fill_in 'edit_box', with: 'this is a test file'
    click_button 'Save changes'
  end
end