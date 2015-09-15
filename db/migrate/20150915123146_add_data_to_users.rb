class AddDataToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string    :location
      t.date      :date_created
      t.date      :last_signed_in
    end
  end
end
