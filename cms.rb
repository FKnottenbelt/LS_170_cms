require 'sinatra'
require "sinatra/reloader" if development?
require "tilt/erubis"
require 'bundler/setup'
require 'sinatra/content_for'
require 'pry' if development?
require 'redcarpet'
require "fileutils"

########## setup ######
configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

before do
  path_pattern = File.join(data_path, "*")
  @files ||= Dir.glob(path_pattern).map { |file| File.basename(file) }.sort
end

######### view helpers #########
module Helpers

end

helpers do
  include Helpers
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

def valid_doc_name?(document_name)
  !(document_name.to_s.empty? || document_name.strip == '')
end
######### routes #########
get '/' do
  erb :files, layout: :layout
end

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

get '/files/new' do
  erb :file_new, layout: :layout
end

post '/files' do
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

get '/:file/edit' do
  @file_name = params[:file]
  file_path = File.join(data_path, @file_name)
  @file_content = File.read(file_path)
  erb :file_edit, layout: :layout
end

post '/:file/edit' do
  @file_name = params[:file]
  file_path = File.join(data_path, @file_name)
  @file_content = params[:edit_box]

  File.open(file_path, 'w') do |f|
     f.write @file_content
  end

  session[:message] = "#{@file_name} has been updated."
  redirect '/'
end