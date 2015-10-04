class UsedAndType < ActiveRecord::Migration
  def up
    change_table :wallpapers do |t|
      t.boolean   :used, default: false
    end

    change_table :powerups do |t|
      t.boolean   :used, default: false
      t.string    :type, default: "player", null: false
    end
  end

  def down

    change_table :wallpapers do |t|
      t.remove :used
    end

    change_table :powerups do |t|
      t.remove :used
      t.remove :type
    end
  end

end
