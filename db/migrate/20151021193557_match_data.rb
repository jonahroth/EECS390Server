class MatchData < ActiveRecord::Migration
  def up
    create_table :matches do |t|
      t.timestamps
      t.datetime    :match_datetime
    end

    create_table :match_participants do |t|
      t.timestamps
      t.integer     :user_id
      t.integer     :match_id
      t.boolean     :winner, default: false
      t.integer     :score,  default: 0
    end
  end

  def down
    drop_table :matches
    drop_table :match_participants
  end
end
