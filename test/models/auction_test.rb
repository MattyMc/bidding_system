require 'test_helper'

class AuctionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  should belong_to :item
  should belong_to :user

  should validate_presence_of :user_id
  should validate_presence_of :item_id
  should validate_presence_of :current_price

  def setup
  	@guitar_auction = auctions(:guitar)
  	@closed_auction = auctions(:closed_auction)
  	@matt = users(:matt)
  end

  	##################
	#### Tests for @auction.close : return true if auction closed, false if error 
	##################
  test "should not allow nil value for is_active" do 
  	assert_raise(ActiveRecord::RecordInvalid) {Auction.create! item_id:5, user_id:5, current_price: 10, is_active:nil}
  end

  test "should return true if auction has closed" do
  	assert @guitar_auction.finish
  end

  test "should return false if auction is already closed" do
  	assert_not @closed_auction.finish
  end

  test "should return appropriate error message if auction has already closed" do
  	@closed_auction.finish
  	assert_equal "auction is already closed", @closed_auction.errors[:error].first
  end

  test "should return appropriate data when auction closes" do 
  	@guitar_auction.finish
  	data = {}
  	data[:winner_id] = users(:matt).id
  	data[:price] = 12.99
   	assert_equal data[:winner_id], @guitar_auction.auction_data[:winner_id]
   	assert_equal data[:price], @guitar_auction.auction_data[:price]
   end

   # test "Auctions.snapshot should return an array" do
   # 	auctions = Auction.snapshot
   # 	assert auctions.class == Array
   # end

   # test "Auctions.snapshot should contain guitar auction"
   # 	auctions = Auction.snapshot
   # 	guitar_auction = {id: @guitar_auction.id, user_id: @matt.id, is_active: true, best_bidder_id: }
   # 	assert auctions.contains {id: }
   # end
end
