class SwitchBuyablesToPackages < ActiveRecord::Migration
  def change
    drop_table :stamps
    drop_table :user_stamps
    drop_table :emojis
    drop_table :equipment
    create_table :packages do |t|
      t.string    :name
      t.integer   :price
      t.text      :description
    end
    create_table :user_packages do |t|
      t.integer   :user_id
      t.integer   :package_id
      t.text      :contents
      t.datetime  :date_purchased
    end
  end
end
