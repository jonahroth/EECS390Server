# get all wallpapers available
get '/api/wallpapers' do
  content_type :json
  Wallpaper.all.to_json
end

get '/api/powerups' do
  content_type :json
  Powerup.all.to_json
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

# purchases a package for a user and deducts peanuts appropriately
# returns a package if purchased, or an empty JSON object if it failed
# (package no longer available, not enough peanuts, etc.)
post '/api/purchase/:userid/:pid' do
  validate params
  package = Package.find_by(:id => params[:pid].to_i)
  user = User.find_by(:id => params[:userid].to_i)
  package_data = nil
  unless !package || user.peanuts < package.price
    user.peanuts -= package.price
    user.save
    package_data = pack_package params[:pid].to_i, params[:userid].to_i
  end

  data = {:package => package_data, :user => user}

  content_type :json
  data.to_json

end

get '/api/inventory/:userid' do
  validate params

  data = new_inventory params[:userid].to_i

  content_type :json
  data.to_json
end

get '/api/inventory/name/:username' do
  validate params
  q = User.find_by(:username => params[:username])
  if q
    data = new_inventory q.id
    content_type :json
    data.to_json
  else
    nil.to_json
  end
end

get '/api/inventory/detailed/:userid' do
  validate params
  data = new_inventory params[:userid].to_i

  content_type :json
  data.to_json
end

# re-rolls the powerups for the given wallpaper.
# returns the new wallpaper and changes the data
# on the server
post '/api/reroll/:userid/:uwid/:internal' do
  validate params
  user_wallpaper = UserWallpaper.find_by(:id => params[:uwid].to_i)
  user = User.find_by(:id => params[:userid].to_i)

  init_check = user && user_wallpaper && user_wallpaper.user_id == user.id
  redirect '/api/invalid' unless init_check

  user_powerups = UserPowerup.where(:user_wallpaper_id => user_wallpaper.id)
  redirect '/api/invalid' if user_powerups.empty?

  this_powerup = user_powerups.find_by(:internal_order => params[:internal].to_i)
  redirect '/api/invalid' if this_powerup.nil?

  valid_powerups = Powerup.all.map {|p| p.id}

  this_powerup.powerup_id = valid_powerups.sample
  this_powerup.save

  user.peanuts -= 600
  user.save

  data = {}
  data[:user_wallpaper] = user_wallpaper
  data[:user_powerups] = user_powerups
  data[:this_powerup] = this_powerup
  data[:peanuts] = user.peanuts

  content_type :json
  data.to_json

end

post '/api/addpower/:userid/:uwid' do
  validate params

  user_wallpaper = UserWallpaper.find_by(:id => params[:uwid].to_i)
  user = User.find_by(:id => params[:userid].to_i)

  init_check = user && user_wallpaper && user_wallpaper.user_id == user.id
  redirect '/api/invalid' unless init_check

  powerup = rnd_powerups(1)[0]
  user_powerup = UserPowerup.create(:user_id => user.id, :user_wallpaper_id => user_wallpaper.id, :powerup_id => powerup.id)

  restore_order user_wallpaper.id

  content_type :json
  user_powerup.to_json
end
