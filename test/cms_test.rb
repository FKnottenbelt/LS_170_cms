require_relative './racktest_helper'

class CmsTest < RackTestCase

  def setup
    FileUtils.mkdir_p(data_path)
  end

  def teardown
    FileUtils.rm_rf(data_path)
  end

  def test_rake_test_have_run
    puts "Rake tests running"
  end

  def session
    last_request.env["rack.session"]
  end

  def admin_session
    {"rack.session" => { username: "admin", signed_in: true}}
  end

  def test_home_page
    create_document "about.txt"
    create_document "changes.txt"
    create_document "history.txt"

    get "/"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes(last_response.body, "about.txt")
    assert_includes(last_response.body, "changes.txt")
    assert_includes(last_response.body, "history.txt")
  end

  ############ View document

  def test_file_page_file_renders_as_plain_tekst
    create_document "about.txt", "Ruby was influenced by Perl"

    get "/about.txt"
    assert_equal 200, last_response.status
    assert_equal "text/plain;charset=utf-8", last_response["Content-Type"]
    assert_includes(last_response.body, "Ruby was influenced by Perl")
  end

  def test_file_page_gives_error_when_file_does_not_exist
    get "/nonexisting.txt", {}, admin_session
    assert_equal 302, last_response.status

    assert_equal "nonexisting.txt does not exist.", session[:message]
  end

  def test_markdown_file_renders_as_html
    create_document "requirement6.md", "<em>Gemfile</em>"

    get "/requirement6.md"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<em>Gemfile</em>"
  end

  ############ Edit a document

  def test_edit_text
    create_document "test.txt"

    get "/test.txt/edit", {}, admin_session
    assert_equal 200, last_response.status
    assert_includes last_response.body, "Edit content of test.txt"
    assert_includes last_response.body, "Documents can be edited now"
  end

  def test_update_text
    create_document "test.txt"

    post "/test.txt/edit", {edit_box: "Did it!"}, admin_session
    assert_equal 302, last_response.status
    assert_equal "test.txt has been updated.", session[:message]

    get "/test.txt"
    assert_equal 200, last_response.status
    assert_includes last_response.body, "Did it!"
  end

  def test_not_signedin_user_can_not_visit_edit_doc_page
    create_document 'test.txt'
    get '/test.txt/edit'
    assert_equal "You must be signed in to do that.", session[:message]
    assert_equal 302, last_response.status
  end

  def test_not_signedin_user_can_not_edit_doc
    create_document 'test.txt'
    post '/test.txt/edit'
    assert_equal "You must be signed in to do that.", session[:message]
    assert_equal 302, last_response.status
  end

  ############ Make a new document

  def test_view_new_document_form
    get "/files/new", {}, admin_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, "<input"
    assert_includes last_response.body, %q(<button type='submit')
  end

  def test_create_new_document
    post "/files", { document_name: "test.txt" }, admin_session
    assert_equal 302, last_response.status

    assert_equal "test.txt was created.", session[:message]

    get "/"
    assert_includes last_response.body, "test.txt"
  end

  def test_create_new_document_without_filename
    post "/files", { document_name: "" }, admin_session
    assert_equal 422, last_response.status
    assert_includes last_response.body, "A name is required"
  end

  def test_valid_document_name
    name = 'test.txt'
    assert_equal(true, valid_doc_name?(name))
  end

  def test_invalid_document_name
    name = ''
    assert_equal(false, valid_doc_name?(name))
    name = '   '
    assert_equal(false, valid_doc_name?(name))
  end

  def test_not_signedin_user_can_not_visit_new_doc_page
    get '/files/new'
    assert_equal "You must be signed in to do that.", session[:message]
    assert_equal 302, last_response.status
  end

  def test_not_signedin_user_can_not_make_new_doc
    post '/files'
    assert_equal "You must be signed in to do that.", session[:message]
    assert_equal 302, last_response.status
  end

  ############ Duplicate a document

  def test_view_duplicate_document_form
    create_document 'test.txt'
    get "/test.txt/duplicate", {}, admin_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Duplicating file test.txt"
    assert_includes last_response.body, %q(<button type='submit')
  end

  def test_duplicate_a_document
    create_document 'test.txt'
    post "/test.txt/duplicate", { document_name: "NEWtest.txt" },
                                admin_session
    assert_equal 302, last_response.status

    assert_equal "NEWtest.txt was created.", session[:message]

    get "/"
    assert_includes last_response.body, "/NEWtest.txt"
    assert_equal(true, same_document_content?('test.txt', 'NEWtest.txt'))
  end

  def test_same_document_content?
    create_document('doc1', "hello world")
    create_document('doc2', "hello world")

    assert_equal(true, same_document_content?('doc1', 'doc2'))
  end

  def test_dupliate_new_document_without_filename
    create_document 'test.txt'
    post "/test.txt/duplicate", { document_name: "" }, admin_session
    assert_equal 422, last_response.status
    assert_includes last_response.body, "A name is required"
  end

  def test_not_signedin_user_can_not_visit_duplicate_doc_page
    get '/test.txt/duplicate'
    assert_equal "You must be signed in to do that.", session[:message]
    assert_equal 302, last_response.status
  end

  def test_not_signedin_user_can_not_duplicate_doc
    post '/test.txt/duplicate'
    assert_equal "You must be signed in to do that.", session[:message]
    assert_equal 302, last_response.status
  end

  ############ Delete a document

  def test_delete_document
    create_document 'test.txt'

    post '/test.txt/delete', { document_name: "test.txt" }, admin_session
    assert_equal 302, last_response.status

    assert_equal "test.txt was deleted", session[:message]

    get "/"
    refute_includes last_response.body, "/test.txt"
  end

  def test_not_signedin_user_can_not_delete_doc
    create_document 'test.txt'

    post '/test.txt/delete'
    assert_equal "You must be signed in to do that.", session[:message]
    assert_equal 302, last_response.status
  end

  ############ Sign in/out

  def test_sign_in_form_exists
    get '/users/sign_in'

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Username"
    assert_includes last_response.body, %q(type='submit')
  end

  def test_user_can_sign_in
    post '/users/sign_in', username: 'admin', password: 'secret'
    assert_equal 302, last_response.status

    assert_equal 'Welcome!', session[:message]
    assert_equal "admin", session[:username]

    get last_response["Location"]
    assert_includes last_response.body, 'Signed in as admin.'
  end

  def test_invalid_user_sign_in_fails
    post '/users/sign_in', username: '', password: ''
    assert_equal 422, last_response.status
    assert_nil session[:username]
   # assert_equal "Invalid Credentials", session[:message]
    assert_includes last_response.body, 'Invalid Credentials'
  end

  def test_user_can_sign_out
    get "/", {}, admin_session
    assert_includes last_response.body, "Signed in as admin"

    post '/users/sign_out'
    assert_equal 302, last_response.status

    assert_equal 'You have been signed out.', session[:message]

    get last_response["Location"]
    assert_nil session[:username]
    assert_includes last_response.body, "Sign In"
  end

  def test_valid_user_gives_true_if_valid_user
    result = valid_user_credentials?('admin', 'secret')
    assert_equal(true, result)
  end

  def test_valid_user_gives_false_if_invalid_user
    result = valid_user_credentials?('anon', 'not saying')
    assert_equal(false, result)
  end

  ############ Users

  def test_user_exists
    assert_equal(true, user_exists?('admin'))
  end

  def test_user_does_not_exist
    assert_equal(false, user_exists?('xqwzrc'))
  end

  def test_delete_user_name
    assert_equal(false, 'not written yet')
  end

  def test_user_name_is_not_empty
    assert_equal(false, valid_user_name?('  '))
    assert_equal(false, valid_user_name?(''))
  end

  def test_user_filled_in_user_name_is_valid
    assert_equal(true, valid_user_name?('Johnny'))
    assert_equal(true, valid_user_name?('Carla May'))
  end

  def test_add_user
    add_user('Tim', 'bazoka')
    assert_equal(true, user_exists?('Tim'))
  end
end
