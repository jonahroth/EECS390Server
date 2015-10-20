class PackageTypeHash < ActiveRecord::Migration
  def up
    change_table :packages do |t|
      t.remove    :min_powerups
      t.remove    :max_powerups
      t.text      :powerup_hash
    end
  end

  def down
    change_table :packages do |t|
      t.remove    :powerup_hash
      t.integer   :min_powerups
      t.integer   :max_powerups
    end
  end

end
