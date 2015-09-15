class AddPeanutsToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.integer :peanuts
    end

    change_table :stamps do |t|
      t.remove  :price
      t.integer :price
    end
  end
end
