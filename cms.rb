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

######### routes #########
get '/' do
  erb :files, layout: :layout
end

get '/:file' do
  file_name = params[:file]
  headers["Content-Type"] = "text/plain"
  file_found = !Dir.glob("./data/#{file_name}").empty?

  if file_found
    @file = File.read("./data/#{file_name}")
    return @file unless file_name =~ /.md/

    headers["Content-Type"] = "text/html"
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    markdown.render(@file)
  else
    session[:message] = "#{file_name} does not exist."
    redirect '/'
  end
end
