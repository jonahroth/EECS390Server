class NewsTable < ActiveRecord::Migration
  def up
    create_table :news do |t|
      t.string    :headline
      t.text      :news_text
      t.timestamps
    end
  end
end
