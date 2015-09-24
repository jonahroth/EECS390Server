class PowerupsAndWallpapers < ActiveRecord::Migration
  def up
    create_table :powerups do |t|
      t.string      :name
      t.string      :path
      t.string      :identifier
      t.text        :description
    end

    create_table :wallpapers do |t|
      t.string      :name
      t.string      :path
      t.string      :identifier
      t.text        :description
    end
  end

  def down
    drop_table :powerups
    drop_table :wallpapers
  end
end
