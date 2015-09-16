class AddRankToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.integer :rank
    end
  end
end
