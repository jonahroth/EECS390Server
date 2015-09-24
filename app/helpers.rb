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

  def rnd_powerups x
    powerups = []
    count = Powerup.count
    x.times do
      powerups.append [Powerup.offset(rand(count)).first]
    end
    powerups.to_json
  end

  def rnd_wallpapers x
    wallpapers = []
    count = Wallpaper.count
    x.times do
      wallpapers.append [Wallpaper.offset(rand(count)).first]
    end
    wallpapers.to_json
  end

end
