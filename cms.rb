require 'sinatra'
require "sinatra/reloader" if development?
require "tilt/erubis"
require 'bundler/setup'

########## setup ######
configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

######### view helpers #########
module Helpers
end

helpers do
  include Helpers
end

######### routes #########
get '/' do
  @files = Dir.glob('./data/*').map { |file| File.basename(file) }.sort
  erb :files, layout: :layout
end