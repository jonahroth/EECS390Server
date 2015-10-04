class AddTimestampsEverywhere < ActiveRecord::Migration
  def up
    change_table :lobby do |t|
      t.remove    :time_added
      t.timestamps
    end

    change_table :packages do |t|
      t.timestamps
    end

    change_table :powerups do |t|
      t.timestamps
    end

  #  change_table :purchasables do |t|
  #    t.timestamps
  #  end

    change_table :user_packages do |t|
      t.remove    :purchase_date
      t.timestamps
    end

#    change_table :user_purchases do |t|
#      t.remove    :purchase_date
#      t.timestamps
#    end

    change_table :users do |t|
      t.remove    :date_created
      t.timestamps
    end

    change_table :wallpapers do |t|
      t.timestamps
    end

    change_table :user_powerups do |t|
      t.timestamps
      t.remove :date_created
    end

    change_table :user_wallpapers do |t|
      t.timestamps
      t.remove :date_created
    end
  end

  def down
    change_table :lobby do |t|
      t.datetime    :time_added
    end

    change_table :user_packages do |t|
      t.datetime    :purchase_date
    end

    change_table :user_purchases do |t|
      t.datetime    :purchase_date
    end

    change_table :users do |t|
      t.datetime    :date_created
    end

    change_table :user_powerups do |t|
      t.datetime :date_created
    end

    change_table :user_wallpapers do |t|
      t.datetime :date_created
    end


  end

end
