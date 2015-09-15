require 'sinatra'
require 'sinatra/activerecord'
require './config/environments' #database configuration
require 'json'
require './models/user'
require 'bcrypt'

enable :sessions

helpers do

  def login?
    if session[:username].nil?
      return false
    else
      return true
    end
  end

  def username
    return session[:username]
  end

end

get '/' do
  erb :index
end

# /login displays HTML to log in
get '/login' do
  erb :login
end

# /validate validates username-password combination
get '/validate' do
  #@user = User.find_by(:username => params[:username], :password => params[:password])

  @user = nil
  if @user = User.find_by(:username => params[:username])
    logger.debug @user.attributes
    if @user.password_hash == BCrypt::Engine.hash_secret(params[:password], @user.salt)
      session[:username] = params[:username]
    end
  end
  content_type :json
  @user ? @user.to_json : {}.to_json
end

# /signup displays HTML to sign up

# /create creates username-password combination
post '/create' do
  #@user = User.new(params[:user])
  #if @user.save
  #  redirect "/about/#{@user.id}"
  #else
  #  redirect "/"
  #end

  puts "PARAMS:"
  puts params

  password_salt = BCrypt::Engine.generate_salt
  password_hash = BCrypt::Engine.hash_secret(params[:user][:password], password_salt)

  @user = User.new
  @user.username = params[:user][:username]
  @user.salt = password_salt
  @user.password_hash = password_hash
  @user.level = 1
  logger.debug @user.username
  logger.debug @user.salt
  @user.save

  session[:username] = params[:user][:username]
  redirect "/about/#{@user.id}"


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
