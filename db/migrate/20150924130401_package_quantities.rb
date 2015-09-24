class PackageQuantities < ActiveRecord::Migration
  def up
    change_table :packages do |t|
      t.integer     :min_powerups
      t.integer     :max_powerups
      t.integer     :min_wallpapers
      t.integer     :max_wallpapers
    end
  end

  def down
    change_table :packages do |t|
      t.remove     :min_powerups
      t.remove     :max_powerups
      t.remove     :min_wallpapers
      t.remove     :max_wallpapers
    end
  end
end
