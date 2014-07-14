class CreateAuctions < ActiveRecord::Migration
  def change
    create_table :auctions do |t|
      t.integer :item_id
      t.integer :user_id
      t.decimal :current_price, precision:10, scale: 2
      t.boolean :is_active

      t.timestamps
    end
  end
end
