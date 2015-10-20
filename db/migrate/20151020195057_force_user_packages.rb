class ForceUserPackages < ActiveRecord::Migration
  def up
    drop_table "user_packages"
    create_table "user_packages", force: :cascade do |t|
      t.text     "wallpapers", default: [], array: true
      t.text     "powerups",   default: [], array: true
      t.integer  "user_id"
      t.integer  "package_id"
      t.timestamps
    end
  end

  def down
    drop_table "user_packages"
    create_table "user_packages", force: :cascade do |t|
      t.text     "wallpapers", default: [], array: true
      t.text     "powerups",   default: [], array: true
      t.integer  "user_id"
      t.integer  "package_id"
      t.timestamps
    end
  end
end
