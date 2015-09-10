require 'sinatra'
require 'sinatra/activerecord'
require './config/environments' #database configuration

get '/' do
  erb :index
end
