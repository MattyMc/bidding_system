class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :item_name
      t.decimal :start_price, precision: 2

      t.timestamps
    end
  end
end
