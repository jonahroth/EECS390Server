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

  if params[:username] != "" && !params[:username].nil? && params[:password] != "" && !params[:password].nil?

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
    @user.last_signed_in = DateTime.now
    @user.save

    session[:username] = params[:user][:username]
    redirect "/about/#{@user.id}"
  else
    redirect '/'
  end

end

# returns info about user id
get '/about/:id' do
  @user = User.find_by(:id => params[:id].to_i)
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

# creates new user with given username/password combination
# requires params: username, password
post '/api/create' do
  password_salt = BCrypt::Engine.generate_salt
  password_hash = BCrypt::Engine.hash_secret(params[:password], password_salt)

  @user = User.new
  @user.username = params[:username]
  @user.salt = password_salt
  @user.password_hash = password_hash
  @user.level = 1
  @user.peanuts = 0
  @user.last_signed_in = DateTime.now
  @user.save

  content_type :json
  @user.to_json
end

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
  User.all.select(:id, :username, :level, :rank).to_json
end

# returns information about a specific user
['/api/user/:id', '/api/user/id/:id'].each do |path|
  get path do
    @user = User.find(params[:id].to_i)
    content_type :json
    @user.to_json
  end
end

# returns information about a specific user by username
get '/api/user/name/:name' do
  @user = User.find_by(:username => params[:name])
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
  Package.create(:name => "Slow Package", :price => 50, :description => "It might contain something and it might not. You never know!", :min_powerups => 0, :max_powerups => 1, :min_wallpapers => 1, :max_wallpapers => 1)
  Package.create(:name => "Regular Package", :price => 100, :description => "Contains a random wallpaper and random powerups.", :min_powerups => 1, :max_powerups => 3, :min_wallpapers => 1, :max_wallpapers => 1)
  Package.create(:name => "Super Package", :price => 400, :description => "Contains 3 random wallpapers for a total of 5 guaranteed random powerups.", :min_powerups => 5, :max_powerups => 5, :min_wallpapers => 3, :max_wallpapers => 3)

  Wallpaper.create(:name => "Birch Wallpaper", :description => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", :identifier => "w_birch")
  Wallpaper.create(:name => "Fire Wallpaper", :description => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", :identifier => "w_fire")
  Wallpaper.create(:name => "Water Wallpaper", :description => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", :identifier => "w_water")

  Powerup.create(:name => "Magic Mushroom", :description => "Does what you think it does.", :identifier => 'p_mushroom')
  Powerup.create(:name => "That star thing", :description => "You move faster and some fun music plays.", :identifier => 'p_star')
  Powerup.create(:name => "Lucky Charms", :description => "This isn't actually a powerup, it's just a breakfast cereal.", :identifier => 'p_charms')


  redirect '/packages'
end

get '/api/invalid' do
  content_type :json
  status 401
  nil.to_json
end
