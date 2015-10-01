class LastSignedInTime < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.remove    :last_signed_in
      t.datetime  :last_signed_in
    end
  end
end
