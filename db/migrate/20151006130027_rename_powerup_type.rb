class RenamePowerupType < ActiveRecord::Migration
  def change
    rename_column :powerups, :type, :power_type
  end
end
