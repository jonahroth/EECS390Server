require 'sinatra'
require 'sinatra/activerecord'
require './config/environments' #database configuration
require 'json'
require './models/user'

get '/' do
  erb :index
end

# /login displays HTML to log in
get '/login' do
  erb :login
end

# /validate validates username-password combination
get '/validate' do
  @user = User.find_by(:username => params[:username], :password => params[:password])
  content_type :json
  @user ? @user.to_json : {}.to_json
end

# /signup displays HTML to sign up

# /create creates username-password combination
post '/create' do
  @user = User.new(params[:user])
  if @user.save
    redirect "/about/#{@user.id}"
  else
    redirect "/"
  end
end

# /about/:id returns info about user id
get '/about/:id' do
  @user = User.find_by(:id => params[:id])
  if @user
    erb :about
  else
    erb :index
  end
end

get '/api/users' do
  content_type :json
  User.all.to_json
end

# /levelup/:id increments level by one

# /level/:id gets level of userid

# /products gets list of products

# /products/:id gets certain product details
