class CreateBuyables < ActiveRecord::Migration
  def change
    create_table :buyables do |t|
      t.string    :name
      t.integer   :price
      t.text      :description
      t.string    :path
    end
  end
end
