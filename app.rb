require 'sinatra'
require 'sinatra/activerecord'
require './config/environments' #database configuration
require 'json'
require './models/user'
require './models/stamp'
require './models/user_stamp'
require './models/lobby'
require 'bcrypt'

enable :sessions

=begin
  SQL table for users currently waiting
  Admin page to create new stamps and perhaps install a set of stamps
=end

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

# displays HTML to sign up
get '/' do
  erb :index
end

# displays HTML to log in
get '/login' do
  erb :login
end

# validates username-password combination
post '/login' do
  @user = nil
  if @user = User.find_by(:username => params[:username])
    if @user.password_hash == BCrypt::Engine.hash_secret(params[:password], @user.salt)
      session[:username] = params[:username]
      redirect "/about/#{@user.id}"
    else
    end
  end
end

post '/validate' do
  if @user = User.find_by(:username => params[:username])
    if @user.password_hash == BCrypt::Engine.hash_secret(params[:password], @user.salt)
      status 204
      body ''
    else
      status 403
      body ''
    end
  end

end

# creates and commits username-password combination
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

# returns info about user id
get '/about/:id' do
  @user = User.find_by(:id => params[:id])
  if @user
    erb :about
  else
    erb :index
  end
end

# displays all stamps with option to purchase
get '/stamps' do
  @stamps = Stamp.all
  @mine = UserStamp.where(:user_id => userid).map {|us| us.stamp_id}
  @peanuts = current_user.peanuts
  erb :stamps
end

# purchases a stamp and redirects to stamp list
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



### API CALLS TO RETURN JSON DATA ###
# (API calls do not use cookies, sessions, or currently encryption/authentication of any kind)

# returns a list of all users
get '/api/users' do
  content_type :json
  User.all.select(:id, :username, :level).to_json
end

# returns information about a specific user
get '/api/user/:id' do
  @user = User.find(params[:id])
  content_type :json
  @user.to_json
end

# returns a list of all stamps with all information
get '/api/stamps' do
  @stamps = Stamp.all
  content_type :json
  @stamps.to_json
end

# returns information about one specific stamp
get '/api/stamp/:id' do
  @stamp = Stamp.find(params[:id])
  content_type :json
  @stamp.to_json
end

# returns information about all stamps owned by specified user
get '/api/stamps/user/:id' do
  my_stamps = UserStamp.where(:user_id => params[:id]).map {|us| us.stamp_id}
  @stamps = Stamp.where(:id => my_stamps)
  content_type :json
  @stamps.to_json
end

# purchases a stamp for a user and deducts peanuts appropriately
# returns a stamp if purchased, or an empty JSON object if it failed
# (stamp no longer available, user already owns, not enough peanuts, etc.)
post '/api/purchase/:userid/:stampid' do
  stamp = Stamp.find_by(:id => params[:stampid])
  user = User.find_by(:id => params[:userid])
  if !stamp || UserStamp.find_by(:user_id => user.id, :stamp_id => stamp.id) || user.peanuts < stamp.price
    stamp = nil
  else
    UserStamp.create(:user_id => user.id, :stamp_id => stamp.id)
    user.peanuts -= stamp.price
    user.save
  end
  content_type :json
  stamp.to_json
end

# increments level by one
post '/api/levelup/:id' do
  begin
    user = User.find(params[:id])
    user.level += 1
    user.save
    content_type :json
    user.to_json
  rescue
    user = nil
    content_type :json
    user.to_json
  end
end

# /level/:id gets level of userid, -1 if error
get '/api/level/:id' do
  begin
    user = User.find(params[:id])
    content_type :json
    user.level
  rescue
    content_type :json
    -1
  end
end

# give some number of peanuts to a user
post '/api/give/:id/:value' do
  user = User.find(params[:id].to_i)
  user.peanuts += params[:value].to_i
  user.save
  content_type :json
  user.to_json
end

# remove all stamps for a user - testing purposes only
get '/api/clear/:id' do
  user = User.find(params[:id])
  UserStamp.destroy_all(:user_id => user.id)
  content_type :json
  UserStamp.all.to_json
end


=begin
post '/api/wait/:id' do
  user = User.find(params[:id])
  lobby.append(user) unless lobby.include? user
  puts request.ip
  worthy_opponents = lobby.select {|u| u != user && u.level == user.level}
  if worthy_opponents.any?
    opponent = worthy_opponents.sample
  end
  # remove user and opponent from lobby
  # notify user and opponent
end
=end
