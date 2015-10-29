class Facebook < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.boolean     :facebook, default: false
      t.string      :name
    end
  end

  def down
    change_table :users do |t|
      t.remove :facebook
      t.remove :name
    end
  end
end
