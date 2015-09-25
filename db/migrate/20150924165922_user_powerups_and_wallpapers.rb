class UserPowerupsAndWallpapers < ActiveRecord::Migration
  def up
    create_table :user_powerups do |t|
      t.integer     :user_id
      t.integer     :user_wallpaper_id
      t.integer     :powerup_id
      t.datetime    :date_created
    end

    create_table :user_wallpapers do |t|
      t.integer     :user_id
      t.integer     :wallpaper_id
      t.datetime    :date_created
    end
  end

  def down
    drop_table :user_powerups
    drop_table :user_wallpapers
  end
end
