class FixUserPackages < ActiveRecord::Migration
  def up
    change_table :user_packages do |t|
      t.integer     :user_id
      t.integer     :package_id
      t.remove      :date_purchased
      t.datetime    :purchase_date
    end
  end
  def down
    change_table :user_packages do |t|
      t.remove     :user_id
      t.remove     :package_id
      t.remove     :purchase_date
      t.datetime   :date_purchased
    end
  end
end
