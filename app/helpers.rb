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

  def jsonize x
    if x.is_a?(Array)
      a = []
      x.each do |i|
        a.append jsonize i
      end
      a
    elsif x.is_a?(Hash)
      a = {}
      x.each do |k, v|
        a[jsonize k] = jsonize v
      end
      a
    else
      x.to_json
    end
  end

  def valid x
    @user = User.find_by(:username => x[:username])
    return false if @user.nil?
    puts x
    puts @user.username
    puts @user.password_hash
    puts BCrypt::Engine.hash_secret(x[:password], @user.salt)
    id_eval = !params[:id] || (params[:id].to_i == @user.id)
    puts "id_eval:" + id_eval.to_s
    @user.last_signed_in = DateTime.now
    @user.save
    return id_eval && @user.password_hash == BCrypt::Engine.hash_secret(x[:password], @user.salt)
  end

  def validate params
    redirect '/api/invalid' unless valid params
  end

  def rnd_powerups x, type = nil
    powerups = []
    if type.nil?
      count = Powerup.count
      x.times do
        powerups.append Powerup.offset(rand(count)).first
      end
    else
      count = Powerup.where(:power_type => type).count
      x.times do
        powerups.append Powerup.where(:power_type => type).offset(rand(count)).first
      end
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
  # optionally, include a type hash of the form {"player" => 2, "platform" => 3}
  # TODO ensure that type hashes are implemented everywhere that packages are created
  def pack_package id, user_id, type_hash = nil, use_hash = false
    data = {}
    data[:package] = Package.find(id)
    data[:wallpapers] = rnd_wallpapers rand((data[:package].min_wallpapers)..(data[:package].max_wallpapers))
    if use_hash
      type_hash |= JSON.parse data[:package].powerup_hash
      data[:powerups] = []
      data[:wallpapers].each do |w|
        these_powerups = []
        type_hash.each do |type, number|
          these_powerups.append rnd_powerups number, type
        end
        data[:powerups].append these_powerups.flatten
      end
    end

    # TODO make each wallpaper in a package have a variable number of powerups

    data[:user_wallpapers] = []
    data[:wallpapers].each do |w|
      data[:user_wallpapers].append UserWallpaper.create(
        :user_id => user_id,
        :wallpaper_id => w.id
      )
    end

    if use_hash
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
  # if detailed == true, also returns the corresponding package,
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
      data[:wallpapers] = Wallpaper.where(:id => UserWallpaper.where(:user_id => user_id).map {|w| w.id}).map {|w| w.attributes}
    end

    return data

  end

  def make_user username, password, facebook

    password_salt = BCrypt::Engine.generate_salt
    password_hash = BCrypt::Engine.hash_secret(password, password_salt)

    @user = nil

    if User.find_by(:username => username) && facebook
      while User.find_by(:username => username).any?
        username = username + rand(10).to_s
      end
    end

    @user = User.new
    @user.username = username
    @user.salt = password_salt
    @user.password_hash = password_hash
    @user.level = 10000
    @user.peanuts = 100
    @user.facebook = !!facebook
    @user.name = facebook[:name] if facebook
    @user.last_signed_in = DateTime.now
    @user.rank = nil
    @user.save

    return @user

  end

  def restore_order uw_id
    uw = UserWallpaper.find_by(:id => uw_id)
    return nil unless uw

    ups = UserPowerup.where(:user_wallpaper_id => uw.id).order(:internal_order)
    max_order = ups.map {|up| up.internal_order}.max
    puts ups

    acc = max_order + 1
    ups.each do |up|
      if up.internal_order < 0
        up.internal_order = acc
        up.save
        acc += 1
      end
    end

  def set_powerups
    Powerup.destroy_all

    CSV.foreach('./assets/csv/powerups.csv') do |row|
      Powerup.create(:name => row[0], :description => row[1], :power_type => row[2], :identifier => row[3])
    end

  end

  def set_wallpapers
    Wallpaper.destroy_all

    CSV.foreach('./assets/csv/wallpapers.csv') do |row|
      Wallpaper.create(:name => row[0], :description => row[1], :identifier => row[2])
    end

  end

end
