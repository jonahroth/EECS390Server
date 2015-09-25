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
      powerups.append Powerup.offset(rand(count)).first
    end
    powerups
  end

  def rnd_wallpapers x
    wallpapers = []
    count = Wallpaper.count
    x.times do
      wallpapers.append Wallpaper.offset(rand(count)).first
    end
    wallpapers
  end

  # creates user entries for a package and returns the appropriate
  # number of associated wallpapers and powerups. DOES NOT spend
  # peanuts or perform any kind of validation
  # TODO known issue: user_wallpaper_id is still assigned incorrectly
  def pack_package id, user_id
    data = {}
    data[:package] = Package.find(id)

    data[:wallpapers] = rnd_wallpapers rand((data[:package].min_wallpapers)..(data[:package].max_wallpapers))
    data[:powerups] = []
    data[:wallpapers].each do |w|
      data[:powerups].append rnd_powerups rand((data[:package].min_powerups)..(data[:package].max_powerups))
    end
    # TODO make each wallpaper in a package have a variable number of powerups

    puts data[:wallpapers].to_json
    puts data[:powerups].to_json

    data[:user_wallpapers] = []
    data[:wallpapers].each do |w|
      data[:user_wallpapers].append UserWallpaper.create(
        :user_id => user_id,
        :wallpaper_id => w.id
      )
    end

    data[:user_powerups] = []
    data[:powerups].each_with_index do |p, i|
      p.each do |powerup|
        data[:user_powerups].append UserPowerup.create(
          :user_id => user_id,
          :powerup_id => powerup.id,
          :user_wallpaper_id => data[:user_wallpapers][i].id
        )
      end
    end

    data[:user_package] = UserPackage.create(
      :user_id => user_id,
      :package_id => id,
      :powerups => data[:powerups].to_json,
      :wallpapers => data[:wallpapers].to_json
    )

    return data
  end

  # returns all UserPackage, UserWallpaper, and UserPowerup items
  # if detailed = true, also returns the corresponding package,
  # wallpaper, and powerup items
  #
  # different from pack_package format in that UserWallpaper
  # objects contain UserPowerup objects
  #
  # assumes user_id has already been validated
  def inventory user_id, detailed = false
    data = {}
    my_wallpapers_raw = UserWallpaper.where(:user_id => user_id)
    my_wallpapers = my_wallpapers_raw.to_a
    my_powerups = UserPowerup.where(:user_id => user_id)
    my_wallpapers.each_with_index do |w, i|
      my_wallpapers[i] = w.attributes
      my_wallpapers[i][:powerups] = my_powerups.where(:user_wallpaper_id => my_wallpapers[i][:id]).map {|w| w.attributes}
    end

    data[:user_wallpapers] = my_wallpapers
    data[:user_powerups] = my_powerups.to_a
    data[:user_packages] = UserPackage.where(:user_id => user_id).to_a

    if detailed
      data[:powerups] = Powerup.where(:id => my_powerups.map {|p| p.id}).map {|p| p.attributes}
      data[:wallpapers] = Wallpaper.where(:id => my_wallpapers_raw.map {|w| w.id}).map {|w| w.attributes} # why doesn't this line work?
    end

    return data

  end

end
