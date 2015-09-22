require 'sinatra'
require 'sinatra/activerecord'
require './config/environments' #database configuration
require 'json'
require './models/user'
require './models/package'
require './models/user_package'
require './models/lobby'
require 'bcrypt'

enable :sessions

=begin TODO
  Ability to remove users from lobby somehow                        << on hold
  On matchmaking - send data about which emojis are equipped, etc   << on hold - need to know how matchmaking is handled
  Framework for purchasing and storing emojis                       << stretch goal
  Check gamedoc - we need info about all equipment that a user has  << on hold - goes along with matchmaking
  Are package contents handled client side or server side?          << server side
    What information does the UI team need?
    Harry and David have more information
  Will payments be handled through Sinatra server or directly from client UI to Google Play?
  Rank - how is rank calculated? Server side or client? What data needs to get sent back to the server and when?
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

  def valid x
    @user = User.find_by(:username => x[:username])
    puts x
    puts @user.username
    puts @user.password_hash
    puts BCrypt::Engine.hash_secret(x[:password], @user.salt)
    id_eval = !params[:id] || (params[:id].to_i == @user.id)
    puts "id_eval:" + id_eval.to_s
    return @user && id_eval && @user.password_hash == BCrypt::Engine.hash_secret(x[:password], @user.salt)
  end

  def validate params
    redirect '/api/invalid' unless valid params
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
  if valid params
    session[:username] = params[:username]
    redirect "/about/#{@user.id}"
  else
    status 401
    body ''
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

# displays all packages with option to purchase
get '/packages' do
  @packages = Package.all.map {|p| [p, UserPackage.where(:user_id => userid, :package_id => p.id).count]}
  puts "@packages"
  puts @packages
  @mine = UserPackage.where(:user_id => userid).map {|us| us.package_id}
  @peanuts = current_user.peanuts
  erb :packages
end

# purchases a package and redirects to package list
post '/packages' do
  if login? && params.any?
    puts "PARAMS:"
    puts params
    package = Package.find(params[:id].to_i)
    if current_user.peanuts >= package.price # && !UserPackage.find_by(:user_id => current_user.id, :package_id => package.id)
      UserPackage.create(:user_id => current_user.id, :package_id => package.id)
      pay_peanuts package.price
    else
    end
    @packages = Package.all.map {|p| [p, UserPackage.where(:user_id => userid, :package_id => p.id).count]}
    puts "@packages"
    puts @packages
    @mine = UserPackage.where(:user_id => userid).map {|us| us.package_id}
    @peanuts = current_user.peanuts
    erb :packages
  else
    redirect '/' #TODO handle invalid requests
  end

end



### API CALLS TO RETURN JSON DATA ###
# (API calls do not use cookies, sessions, or currently encryption/authentication of any kind)

# returns status 204 if username-password combination is correct, 401 if not
post '/api/validate' do
  if valid params
    status 204
    body ''
  else
    status 401
    body ''
  end
end

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

# returns a list of all packages with all information
get '/api/packages' do
  @packages = Package.all
  content_type :json
  @packages.to_json
end

# returns information about one specific package
get '/api/package/:id' do
  @package = Package.find(params[:id])
  content_type :json
  @package.to_json
end

# returns information about all packages owned by specified user
get '/api/packages/user/:id' do
  validate params
  my_packages = UserPackage.where(:user_id => params[:id]).map {|us| us.package_id}
  @packages = Package.where(:id => my_packages)
  content_type :json
  @packages.to_json
end

# purchases a package for a user and deducts peanuts appropriately
# returns a package if purchased, or an empty JSON object if it failed
# (package no longer available, not enough peanuts, etc.)
post '/api/purchase/:userid/:pid' do
  validate params
  package = Package.find_by(:id => params[:pid])
  user = User.find_by(:id => params[:userid])
  if !package || user.peanuts < package.price
    package = nil
  else
    UserPackage.create(:user_id => user.id, :package_id => package.id)
    user.peanuts -= package.price
    user.save
  end
  content_type :json
  package.to_json
end

# increments level by one
post '/api/levelup/:id' do
  validate params
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
  validate params
  user = User.find(params[:id].to_i)
  user.peanuts += params[:value].to_i
  user.save
  content_type :json
  user.to_json
end

# remove all packages for a user - testing purposes only
get '/api/clear/:id' do
  validate params
  user = User.find(params[:id])
  UserPackage.destroy_all(:user_id => user.id)
  content_type :json
  UserPackage.all.to_json
end

# add a user to the lobby
post '/api/wait/:id' do
  validate params
  lobby = Lobby.all.to_a
  puts lobby
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

# view all users in the lobby
get '/api/lobby' do
  lobby = Lobby.all.map { |l| [l.user_id, l.time_added, User.find(l.user_id).username] }
  content_type :json
  lobby.to_json
end

get '/setup' do
  Package.create(:name => "Slow Package", :price => 50, :description => "It might contain something and it might not. You never know!")
  Package.create(:name => "Regular Package", :price => 100, :description => "Contains a random wallpaper and random powerups.")
  Package.create(:name => "Super Package", :price => 250, :description => "Contains 3 random wallpapers for a total of 5 random powerups.")
  redirect '/packages'
end

get '/api/invalid' do
  content_type :json
  status 401
  nil.to_json
end
