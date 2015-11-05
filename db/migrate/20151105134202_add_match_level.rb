class AddMatchLevel < ActiveRecord::Migration
  def up
    change_table :matches do |t|
      t.string    :level, default: "birch"
    end
  end

  def down
    t.remove      :level
  end
end
