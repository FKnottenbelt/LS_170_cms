require 'sinatra'
require "sinatra/reloader" if development?
require "tilt/erubis"
require 'bundler/setup'
require 'sinatra/content_for'
require 'pry' if development?
require 'redcarpet'

########## setup ######
configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

before do
  @files ||= Dir.glob('./data/*').map { |file| File.basename(file) }.sort
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

def get_file_content(file_name)
  @file = File.read("./data/#{file_name}")
  headers["Content-Type"] = "text/plain;charset=utf-8"
  return @file unless file_name =~ /.md/
  render_markdown(@file)
end

######### routes #########
get '/' do
  erb :files, layout: :layout
end

get '/:file' do
  file_name = params[:file]
  file_found = File.exist?("./data/#{file_name}")

  if file_found
    get_file_content(file_name)
  else
    session[:message] = "#{file_name} does not exist."
    redirect '/'
  end
end
