require 'test_helper'

class AuctionTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false 
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
	#### Tests for @auction.finish : return true if auction closed, false if error 
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

  test "should have matt as highest bidder" do
    assert_equal @matt, @guitar_auction.best_bidder
  end

  test "should reduce blocked_budget by the final auction price" do
    @guitar_auction.finish
    @matt.reload
    assert_equal 12.01, @matt.blocked_budget.to_f
  end

  test "should return appropriate data when auction closes" do 
  	@guitar_auction.finish
  	data = {}
  	data[:winner_id] = users(:matt).id
  	data[:price] = 12.99
   	assert_equal data[:winner_id], @guitar_auction.auction_data[:winner_id]
   	assert_equal data[:price], @guitar_auction.auction_data[:price]
   end
  
  test "should add item_id to user's owned items" do
    @guitar_auction.finish
    @matt.reload
    assert @matt.owned_item_ids.include? items(:guitar).id
  end
  
  ##################
  #### Tests for Auction.snapshot
  ##################
  
   test "Auction.snapshot should return an array" do
   	auctions = Auction.snapshot
   	assert auctions.class == Array
   end

   test "Auction.snapshot should contain guitar auction" do
   	auctions = Auction.snapshot
   	assert auctions.include? @guitar_auction.attributes.except("created_at", "updated_at")
   end

   test "Auction.snapshot should not return created_at or updated_at" do
    auctions = Auction.snapshot
    auctions.each do |auction|
      assert auction["created_at"].nil?
      assert auction["updated_at"].nil?
    end
   end
end
