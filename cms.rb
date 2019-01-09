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

SUPPORTED_EXTENTIONS = ['txt', 'md', 'png', 'jpg']

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

def render_png(file)
  headers["Content-Type"] = "image/png"
  file
end

def get_file_content(file_path)
  @file = File.read(file_path)
  if file_path =~ /.md/
    render_markdown(@file)
  elsif file_path =~ /.png/
    render_png(@file)
  elsif file_path =~ /.jpg/
    render_png(@file)
  else
    @file
  end
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

def upload_file(url)
  filename = File.basename(url)
  destination = File.join(data_path, filename)
  FileUtils.cp(url, destination)
end

def valid_doc_name?(document_name)
  !(document_name.to_s.empty? || document_name.strip == '') &&
  extention_supported?(document_name)
end

def extention_supported?(filename)
  _, extention = File.basename(filename).split('.')
  SUPPORTED_EXTENTIONS.include?(extention)
end

def write_versioned_file(file)
  timestamp = Time.now.strftime("%Y%m%d%H%M%S")

  file_without_extention, extention = file.split('.')
  extention = ".#{extention}" if extention

  versioned_file = "#{file_without_extention}_#{timestamp}#{extention}"
  File.rename(File.join(data_path,file),
              File.join(data_path,versioned_file))
end

def block_not_signed_in_users
  if session[:signed_in] == false
    session[:message] = "You must be signed in to do that."
    redirect '/'
  end
end

def user_credentials_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/users.yml", __FILE__)
  else
    File.expand_path("../users.yml", __FILE__)
  end
end

def load_user_credentials
  credentials_path = user_credentials_path
  YAML.load_file(credentials_path)
end

def valid_user_name?(username)
  !(username.to_s.empty? || username.strip == '')
end

def valid_user_credentials?(username, password_attempt)
  user_credentials = load_user_credentials
  stored_password = user_credentials[username]

  if user_credentials.has_key?(username)
    bcrypt_password = BCrypt::Password.new(stored_password)
    bcrypt_password == password_attempt
  else
    false
  end
end

def add_user(username, password)
  bcrypt_password = BCrypt::Password.create(password).to_s
  new_user = "\n#{username}: #{bcrypt_password}"

  File.write(user_credentials_path, new_user, mode: 'a')
end

######### routes #########
get '/' do
  @signed_in = session[:signed_in]
  @username = session[:username] if @signed_in
  erb :files, layout: :layout
end

# Go to create new user page
get '/users/new' do
  session[:message] = 'Creating new user account'
  erb :users_sign_up
end

# Create new user
post '/users/new' do
  if user_exists?(params[:username])
    status 422
    session[:message] = 'This username allready exists,
    please choose another username'
    erb :users_sign_up
  elsif valid_user_name?(params[:username])
    add_user(params[:username], params[:password])

    session[:signed_in] = true
    @username = session[:username] = params[:username]
    session[:message] = 'Welcome!'
    redirect '/'
  else
    status 422
    session[:message] = 'Invalid Credentials'
    erb :users_sign_up
  end
end

# Go to user sign in page
get '/users/sign_in' do
  erb :users_sign_in, layout: :layout
end

# Sign in user
post '/users/sign_in' do
  if valid_user_credentials?(params[:username], params[:password])
    session[:signed_in] = true
    @username = session[:username] = params[:username]
    session[:message] = 'Welcome!'
    redirect '/'
  else
    status 422
    session[:message] = 'Invalid Credentials'
    erb :users_sign_in, layout: :layout
  end
end

# Sign out user
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

  write_versioned_file(@file_name)
  File.write(file_path, @file_content, mode:'w')

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

# Go to upload document page
get '/files/upload' do
  block_not_signed_in_users

  erb :file_upload
end

# Upload file
post '/files/upload' do
  block_not_signed_in_users

  url = params[:document_name]
  if (valid_doc_name?(url))
    upload_file(url)
    filename = File.basename(url)
    session[:message] = "#{filename} has been uploaded"
    redirect '/'
  else
    status 422
    session[:message] = "This is not a valid document name"
    erb :file_upload
  end
end