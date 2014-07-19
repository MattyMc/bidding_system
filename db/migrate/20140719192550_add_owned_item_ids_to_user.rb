class AddOwnedItemIdsToUser < ActiveRecord::Migration
  def change
    add_column :users, :owned_item_ids, :text
  end
end
