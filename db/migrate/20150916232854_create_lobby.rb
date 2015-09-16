class CreateLobby < ActiveRecord::Migration
  def change
    create_table :lobby do |t|
      t.integer   :user_id
      t.datetime  :time_added
    end
  end
end
