class UserDefaults < ActiveRecord::Migration
  def up
    change_column_default :users, :level, 1
    change_column_default :users, :rank, 10000
  end

  def down
    change_column_default :users, :level, nil
    change_column_default :users, :rank, nil

  end
end
