class UserPowerupInternalOrder < ActiveRecord::Migration
  def up
    change_table :user_powerups do |t|
      t.integer   :internal_order, default: -1
    end
  end

  def down
    change_table :user_powerups do |t|
      t.remove :internal_order
    end
  end
end
