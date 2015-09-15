require 'sinatra'
require 'sinatra/activerecord'
require './config/environments' #database configuration
require 'json'
require './models/user'
require './models/stamp'
require './models/user_stamp'
require 'bcrypt'

=begin

  /
  /login
  /validate
  /create
  /users
  /stamps
  /about/:id
  /purchase/:userid/:stampid

  /api
    /validate
    /create
    /users
    /stamps
    /about/:id
    /purchase/:userid/:stampid

=end

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
    session[:username]
  end

  def userid
    User.find_by(:username => session[:username]).id
  end

  def current_user
    User.find_by(:username => session[:username])
  end

  def pay_peanuts i
    me = User.find_by(:username => session[:username])
    me.peanuts -= i
    me.save
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
post '/validate' do

  @user = nil
  if @user = User.find_by(:username => params[:username])
    logger.debug @user.attributes
    if @user.password_hash == BCrypt::Engine.hash_secret(params[:password], @user.salt)
      session[:username] = params[:username]
    end
  end
  redirect "/about/#{@user.id}"
end

# /signup displays HTML to sign up

# /create creates username-password combination
post '/create' do

  puts "PARAMS:"
  puts params

  password_salt = BCrypt::Engine.generate_salt
  password_hash = BCrypt::Engine.hash_secret(params[:user][:password], password_salt)

  @user = User.new
  @user.username = params[:user][:username]
  @user.salt = password_salt
  @user.password_hash = password_hash
  @user.level = 1
  @user.peanuts = 0
  @user.date_created = Time.now
  @user.last_signed_in = Time.now
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

get '/stamps' do
  @stamps = Stamp.all
  @mine = UserStamp.where(:user_id => userid).map {|us| us.stamp_id}
  @peanuts = current_user.peanuts
  erb :stamps
end

post '/purchase' do
  if login? && params.any?
    puts "PARAMS:"
    puts params
    stamp = Stamp.find(params[:id].to_i)
    if current_user.peanuts >= stamp.price && !UserStamp.find_by(:user_id => current_user.id, :stamp_id => stamp.id)
      UserStamp.create(:user_id => current_user.id, :stamp_id => stamp.id)
      pay_peanuts stamp.price
    else
    end
    redirect '/stamps'
  else
    redirect '/' #TODO handle invalid requests
  end
end

get '/api/users' do
  content_type :json
  User.all.to_json
end

get '/api/user/:id' do
  @user = User.find(params[:id])
  content_Type :json
  @user.to_json
end

get '/api/stamps' do

end

get '/api/stamp/:id' do

end

# /levelup/:id increments level by one

# /level/:id gets level of userid

# /products gets list of products

# /products/:id gets certain product details
