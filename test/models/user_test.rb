require 'test_helper'

class UserTest < ActiveSupport::TestCase
	# Since we are using transactional fixtures
	self.use_transactional_fixtures = false 

	should have_many :items
	should have_many :auctions

	should validate_presence_of :budget
	should validate_presence_of :blocked_budget


	def setup
		@matt = users(:matt)
		@pam = users(:pam)
		@jay = users(:jay)
		@olivia = users(:olivia)

		@teddy_bear = items(:teddy_bear) # This auction is closed
		@guitar = items(:guitar) # This auction is open, price is $12.99 (matt)
	end

  test "should create new user" do
  	user = User.new budget: 12.95, blocked_budget: 0
    assert user.save 
  end

  test "should not accept bid if no auction found" do
  	assert_not @matt.bid 20, 2
  end

  test "should return insufficient funds user's budget insufficient" do
  	@pam.bid @guitar.id, 30.00
  	assert_equal "insufficient funds", @pam.errors[:error].first
  end

  test "should not allow bid if user's budget insufficient" do
  	bid_result = @pam.bid @guitar.id, 30.00
  	assert_not bid_result
  end

  test "should return false if auction is closed" do 
  	bid_result = @pam.bid @teddy_bear.id, 25
  	assert_not bid_result
  end

  test "should not modify budget if auction is closed" do 
  	bid_result = @pam.bid @teddy_bear.id, 25
  	assert_not_equal @pam, auctions(:closed_auction).user
  end

  test "should add error message if auction is closed" do 
  	@pam.bid @teddy_bear.id, 25
  	assert_equal "auction is closed", @pam.errors[:error].first
  end

  test "should return false if bid amount is lower than current auction price" do
  	bid_result = @pam.bid @guitar.id, 12.98
  	assert_not bid_result
  end

  test "should add error message if bid amount is lower than auction price" do
  	 @pam.bid @guitar.id, 12.98
  	 assert_equal "invalid amount", @pam.errors[:error].first
  end

  test "should not accept an equal bid" do
  	bid_result = @pam.bid @guitar.id, 12.99
  	assert_not bid_result
  end

  # Pam bids on Matt's guitar
  test "should accept higher bid" do 
  	bid_result = @pam.bid @guitar.id, 13.00
  	assert bid_result
  end

  test "should reduce bidder's budget after bid" do
  	pams_budget = @pam.budget
  	@pam.bid @guitar.id, 13.00
  	pams_budget -= 13.00
  	assert_equal pams_budget, @pam.reload.budget
  end

  test "should increase bidder's blocked_budget" do
  	pams_blocked_budget = @pam.blocked_budget
  	@pam.bid @guitar.id, 13.00
  	pams_blocked_budget += 13.00
  	assert_equal pams_blocked_budget, @pam.reload.blocked_budget
  end

  test "should decrease old highest bidder's blocked budget" do
  	matts_old_bid = auctions(:guitar).current_price
  	matts_blocked_budget = @matt.blocked_budget
  	@pam.bid @guitar.id, 13.00
  	matts_blocked_budget -= matts_old_bid
  	assert_equal matts_blocked_budget.to_f, @matt.reload.blocked_budget.to_f
  end

  test "should increase old highest bidder's budget" do
  	matts_old_bid = auctions(:guitar).current_price
  	matts_budget = @matt.budget
  	@pam.bid @guitar.id, 13.00
  	matts_budget += matts_old_bid
  	assert_equal matts_budget.to_f, @matt.reload.budget.to_f
  end

  test "should update new auction current_price" do
  	@pam.bid @guitar.id, 13.00
  	assert_equal 13.00, auctions(:guitar).current_price
  end

  test "should update new auction highest_bidder" do
  	@pam.bid @guitar.id, 13.00
  	assert_equal @pam, auctions(:guitar).user
  end



end
