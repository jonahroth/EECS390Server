class AddStamps < ActiveRecord::Migration
  def up
    create_table :stamps do |t|
      t.string  :name
      t.text    :description
      t.float   :price
    end

    create_table :user_stamps do |t|
      t.integer   :user_id
      t.integer   :stamp_id
      t.date      :date_purchased
    end
  end

  def down
    drop_table :stamps
    drop_table :user_stamps
  end
end
