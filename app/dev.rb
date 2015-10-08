get '/dev/csv/powerup' do

  require 'csv'

  Powerup.destroy_all

  CSV.foreach('./assets/csv/powerups.csv') do |row|
    Powerup.create(:name => row[0], :description => row[1], :power_type => row[2], :identifier => row[3])
  end

  "success".to_json

end


get '/dev/csv/wallpaper' do

  require 'csv'

  Wallpaper.destroy_all

  CSV.foreach('./assets/csv/wallpapers.csv') do |row|
    Wallpaper.create(:name => row[0], :description => row[1], :identifier => row[2])
  end

  "success".to_json

end
