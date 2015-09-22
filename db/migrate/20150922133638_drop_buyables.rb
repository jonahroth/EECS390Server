class DropBuyables < ActiveRecord::Migration
  def change
    drop_table :buyables
  end
end
