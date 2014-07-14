class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :item_name
      t.decimal :start_price, scale: 2, precision: 10

      t.timestamps
    end
  end
end
