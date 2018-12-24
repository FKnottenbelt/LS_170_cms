require 'sinatra'
require "sinatra/reloader" if development?
require "tilt/erubis"
require 'bundler/setup'
require 'sinatra/content_for'
require 'pry' if development?

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
  headers["Content-Type"] = "text/plain"
  file_found = !Dir.glob("./data/#{params[:file]}").empty?

  if file_found
    @file = File.read("./data/#{params[:file]}")
  else
    session[:message] = "#{params[:file]} does not exist."
    redirect '/'
  end
end