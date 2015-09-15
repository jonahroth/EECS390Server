class AddSecurePasswordToUsers < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.string :salt
      t.string :password_hash
      t.remove :password
    end
  end
end
