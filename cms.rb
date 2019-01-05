require 'sinatra'
require "sinatra/reloader" if !production?
require "tilt/erubis"
require 'bundler/setup'
require 'sinatra/content_for'
require 'pry' if !production?
require 'redcarpet'
require "fileutils"
require 'yaml'
require 'bcrypt'

########## setup ######
configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

before do
  path_pattern = File.join(data_path, "*")
  @files ||= Dir.glob(path_pattern).map { |file| File.basename(file) }.sort

  session[:signed_in] ||= false
end

######### helper methods #########
def render_markdown(file)
  headers["Content-Type"] = "text/html;charset=utf-8"
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(file)
end

def get_file_content(file_path)
  @file = File.read(file_path)
  return @file unless file_path =~ /.md/
  render_markdown(@file)
end

def data_path # get absolute path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end

def create_document(name, content = "")
  File.open(File.join(data_path, name), "w") do |file|
    file.write(content)
  end
end

def same_document_content?(doc1, doc2)
  doc1_content = get_file_content(File.join(data_path, doc1))
  doc2_content = get_file_content(File.join(data_path, doc2))
  doc1_content == doc2_content
end

def valid_doc_name?(document_name)
  !(document_name.to_s.empty? || document_name.strip == '')
end

def block_not_signed_in_users
  if session[:signed_in] == false
    session[:message] = "You must be signed in to do that."
    redirect '/'
  end
end

def load_user_credentials
  credentials_path = if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/users.yml", __FILE__)
  else
    File.expand_path("../users.yml", __FILE__)
  end
  YAML.load_file(credentials_path)
end

def valid_user?(username, password_attempt)
  user_credentials = load_user_credentials
  stored_password = user_credentials[username]

  if user_credentials.has_key?(username)
    bcrypt_password = BCrypt::Password.new(stored_password)
    bcrypt_password == password_attempt
  else
    false
  end
end

######### routes #########
get '/' do
  @signed_in = session[:signed_in]
  @username = session[:username] if @signed_in
  erb :files, layout: :layout
end

get '/users/sign_in' do
  erb :sign_in, layout: :layout
end

post '/users/sign_in' do
  if valid_user?(params[:username], params[:password])
    session[:signed_in] = true
    @username = session[:username] = params[:username]
    session[:message] = 'Welcome!'
    redirect '/'
  else
    status 422
    session[:message] = 'Invalid Credentials'
    erb :sign_in, layout: :layout
  end
end

post '/users/sign_out' do
  session[:signed_in] = false
  session.delete :username
  session[:message] = "You have been signed out."
  redirect '/'
end

# View document
get '/:file' do
  file_name = params[:file]
  file_path = File.join(data_path, file_name)
  file_found = File.exist?(file_path)
  headers["Content-Type"] = "text/plain;charset=utf-8"

  if file_found
    get_file_content(file_path)
  else
    session[:message] = "#{file_name} does not exist."
    redirect '/'
  end
end

# Go to new document page
get '/files/new' do
  block_not_signed_in_users
  erb :file_new, layout: :layout
end

# Make a new document
post '/files' do
  block_not_signed_in_users

  if valid_doc_name?(params[:document_name])
    create_document(params[:document_name])
    session[:message] = "#{params[:document_name]} was created."
    redirect '/'
  else
    session[:message] = "A name is required."
    status 422 # Unprocessable Entity
    erb :file_new, layout: :layout
  end
end

# Go to duplicate document page
get '/:file/duplicate' do
  block_not_signed_in_users

  @file_name = params[:file]
  erb :file_duplicate
end

# Duplicate a document
post '/:file/duplicate' do
  block_not_signed_in_users

  @file_name = params[:file]
  @new_file_name = params[:document_name]

  if valid_doc_name?(@new_file_name)

    file_path = File.join(data_path, @file_name)
    @file_content = File.read(file_path)

    create_document(@new_file_name, @file_content)
    session[:message] = "#{@new_file_name} was created."
    redirect '/'
  else
    session[:message] = "A name is required."
    status 422
    erb :file_duplicate
  end
end

# Go to edit document page
get '/:file/edit' do
  block_not_signed_in_users

  @file_name = params[:file]
  file_path = File.join(data_path, @file_name)
  @file_content = File.read(file_path)
  erb :file_edit, layout: :layout
end

# Edit a document
post '/:file/edit' do
  block_not_signed_in_users

  @file_name = params[:file]
  file_path = File.join(data_path, @file_name)
  @file_content = params[:edit_box]

  File.write(file_path, @file_content)

  session[:message] = "#{@file_name} has been updated."
  redirect '/'
end

# Delete document
post '/:file/delete' do
  block_not_signed_in_users

  file_path = File.join(data_path, params[:file])
  File.delete(file_path)
  session[:message] = "#{params[:file]} was deleted"
  redirect '/'
end

