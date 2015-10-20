class RemovePurchasableTable < ActiveRecord::Migration
  def change
    drop_table :purchasables
    drop_table :user_purchases
  end
end
