class CreateEquipment < ActiveRecord::Migration
  def change
    create_table :equipment do |t|
      t.string    :name
      t.integer   :price
      t.text      :description
      t.string    :path
    end
    create_table :emojis do |t|
      t.string    :name
      t.integer   :price
      t.text      :description
      t.string    :path
    end
    change_table :stamps do |t|
      t.string    :path
    end
  end
end
