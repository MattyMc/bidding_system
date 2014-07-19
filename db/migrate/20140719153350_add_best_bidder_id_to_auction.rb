class AddBestBidderIdToAuction < ActiveRecord::Migration
  def change
  	add_column :auctions, :best_bidder_id, :integer
  end
end
