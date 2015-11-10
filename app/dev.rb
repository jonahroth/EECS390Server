post '/dev/setup' do
  [Powerup, Wallpaper, Package, UserPackage, UserWallpaper, UserPowerup].each do |m|
    m.destroy_all
  end

  set_powerups
  set_wallpapers

  Package.create(:name => "Package", :price => 1000, :min_wallpapers => 1, :max_wallpapers => 1, :description => "One wallpaper, fillable up to three powerups", :powerup_hash => '{"player":2,"platform":1}')

  content_type :json
  "success".to_json

end

get '/dev/csv/powerup' do

  set_powerups
  "success".to_json

end


get '/dev/csv/wallpaper' do

  set_wallpapers
  "success".to_json

end
