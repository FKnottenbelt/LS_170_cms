require_relative './capybara_helper'

class CmsAcceptTest < CapybaraTestCase

  def setup
    FileUtils.mkdir_p(data_path)
    admin_session
  end

  def teardown
    FileUtils.rm_rf(data_path)
    log_out
  end

  def test_acc_test_have_run
    puts "Acc tests running"
  end

  def admin_session
    visit '/'
    if (page.has_button?('Sign In'))
      click_button 'Sign In'
      fill_in 'username', with: 'admin'
      fill_in 'password', with: 'secret'
      click_button 'Sign In'
    end
  end

  def log_out
    visit '/'
    if (page.has_button?('Sign Out'))
      click_button "Sign Out"
    end
  end

  def test_clicking_file_opens_file
    create_document "about.txt", "Ruby was influenced by Perl"

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
    create_document "requirement6.md", "<em>Gemfile</em>"
    create_document "test.txt"
    create_document "changes.txt"

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
  end

  def test_create_new_document
    # when I view the homepage
    visit '/'
    # and I see and click the new document link
    assert_link 'New Document'
    click_link 'New Document'
    # I go to the add new doc page
    assert_current_path '/files/new'
    # I see a label "Add a new document"
    assert_content "Add a new document"
    # if I enter a new document 'test.txt'
    fill_in 'document_name', with: 'test.txt'
    # and I click the create button
    click_button 'Create'
    # I should be redirected to the index page
    assert_current_path '/'
    # where I see my new file in the list
    assert_content 'test.txt'
    # and get a succes message
    assert_content 'test.txt was created.'
  end

  def test_create_empty_doc_fails
    # I go to the add new doc page
    visit '/files/new'
    # if I don't enter a new document
    fill_in 'document_name', with: ''
    # and I click the create button
    click_button 'Create'
    # I should be returned to the files new page
    assert_current_path '/files'
    # where I see an error message
    assert_content 'A name is required.'
  end

  def test_delete_document
    create_document("acctest.txt")

    # when I view the homepage
    visit '/'
    # and I see and click the delete button
    click_button 'Delete'
    # I wil still be on the home page
    assert_current_path '/'
    # but my file is gone
    refute_content "acctest.txt</a>"
  end

  def test_user_can_sign_in_as_admin
    # when I view the homepage and am not logged in
    log_out
    visit '/'
    # and I click the sign in button
    click_button 'Sign In'
    # I go to the sign in page
    assert_current_path '/users/sign_in'
    # I fill in the fields as user admin
    fill_in 'username', with: 'admin'
    fill_in 'password', with: 'secret'
    # and I click the sign in button
    click_button 'Sign In'
    # I get redirected to the home page
    assert_current_path '/'
    # where I get a succes message
    assert_content 'Welcome!'
    # see my user name
    assert_content 'Signed in as admin.'
    # and a sign out button
    assert_button 'Sign Out'
  end

  def test_user_can_not_sign_in_if_not_admin
    # when I view the homepage and am not logged in
    log_out
    visit '/'
    # and I click the sign in button
    click_button 'Sign In'
    # I go to the sign in page
    assert_current_path '/users/sign_in'
    # I fill in the fields as non admin
    fill_in 'username', with: ''
    fill_in 'password', with: ''
    # and I click the sign in button
    click_button 'Sign In'
    # I will still be on the sign in page
    assert_current_path '/users/sign_in'
    # and see a failure message
    assert_content 'Invalid Credentials'
  end

  def test_user_can_sign_out
    # if I am signed in (in setup)
    visit '/'
    # I see a sign out button
    assert_button 'Sign Out'
    # which I can click
    click_button 'Sign Out'
    # and I see a succes message
    assert_content 'You have been signed out.'
  end

  def test_user_can_duplicate_doc
    create_document("acctest.txt")
    # when I view the homepage
    visit '/'
    # and I see and click the duplicate document button
    assert_button 'Duplicate'
    click_button 'Duplicate'
    # I go to the duplciate doc page
    assert_current_path '/acctest.txt/duplicate'
    # I see a label "Add a new document"
    assert_content "Add a new document name"
    assert_content "Duplicating file acctest.txt"
    # if I enter a new document 'Newacctest.txt'
    fill_in 'document_name', with: 'Newacctest.txt'
    # and I click the create button
    click_button 'Create'
    # I should be redirected to the index page
    assert_current_path '/'
    # where I see my new file in the list
    assert_content 'Newacctest.txt'
    # and get a succes message
    assert_content 'Newacctest.txt was created.'
  end
end