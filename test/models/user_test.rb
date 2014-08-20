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
    @hockey_stick = items(:hockey_stick)
	end

	##################
	#### Tests for creating new user & User.add_user id, budget
	##################

  test "should create new user" do
  	user = User.new id:1234, budget: 12.95, blocked_budget: 0
    assert user.save 
  end

  test "should return user if completed successfully" do
  	a = User.create id:20, budget:30.50, blocked_budget:0
  	assert_equal a, User.find_by_id(20)
  end

  test "should save a new user" do
  	m = User.create id:20, budget:500.25, blocked_budget:0
  	assert User.find(20)
  	assert User.find(20).budget.to_f == 500.25
  end

  test "should not allow a user with a duplicate id to be added" do
  	assert_raise(ActiveRecord::RecordNotUnique) {User.create! id:@pam.id, budget:50, blocked_budget:0}
  end

  test "should not allow a user with invalid budget" do
  	assert_raise(ActiveRecord::RecordInvalid) { User.create! id:52, budget:21.233, blocked_budget:0 }
  end

  test "should not allow add_user to have three decimal places" do
  	exception = assert_raise(ActiveRecord::RecordInvalid) {User.create! id:52, budget:21.233, blocked_budget:0}
  	assert_equal "Validation failed: Budget has too many decimal places", exception.message
  end
  	##################
	#### Tests for User.bid item_id, amount
	##################

  test "should raise exception if no auction found" do
  	assert_raise(ActiveRecord::RecordNotFound) {@matt.bid 20, 2}
  end

  test "should return insufficient funds if user's budget is insufficient" do
  	exception = assert_raise(User::InvalidBid) {@pam.bid @guitar.id, 30.00}
  	assert_equal "insufficient funds", exception.message
  end

  test "should not allow bid if user's budget insufficient" do
  	exception = assert_raise(User::InvalidBid) {@pam.bid @guitar.id, 30.00}
  	assert_equal "insufficient funds", exception.message
  end

  test "should return false if auction is closed" do 
  	exception = assert_raise(User::InvalidBid) {@pam.bid @teddy_bear.id, 25}
  	assert_equal "auction is closed", exception.message
  end

  test "should not modify budget if auction is closed" do 
  	exception = assert_raise(User::InvalidBid) {@pam.bid @teddy_bear.id, 25}
  	assert_not_equal @pam, auctions(:closed_auction).user
  	assert_equal "auction is closed", exception.message
  end

  test "should raise error and add error message if auction is closed" do 
  	exception = assert_raise (User::InvalidBid) { @pam.bid @teddy_bear.id, 25 }
  	assert_equal "auction is closed", exception.message
  end

  test "should raise error if bid amount is lower than current auction price" do
  	exception = assert_raise(User::InvalidBid) {@pam.bid @guitar.id, 12.98}
  	assert_equal "invalid amount", exception.message
  end

  test "should not accept an equal bid" do
  	exception = assert_raise(User::InvalidBid) {@pam.bid @guitar.id, 12.99}
  	assert_equal "invalid amount", exception.message
  end

  test "should accept a higher bid from the same user" do 
  	assert @matt.bid(@guitar.id, "13.50")
  end

  test "should correctly adjust budget if higher bid from same user" do
  	new_budget = @matt.budget + 12.99 - 13.50
  	new_blocked_budget = @matt.blocked_budget - 12.99 + 13.50
  	@matt.bid @guitar.id, "13.50"
  	@matt.reload

  	assert_equal new_budget.to_f, @matt.budget.to_f
  	assert_equal new_blocked_budget.to_f, @matt.blocked_budget.to_f
  end


  # Pam bids on Matt's guitar
  test "should accept higher bid" do 
  	bid_result = @pam.bid @guitar.id, 13.00
  	assert bid_result
  end

  test "should reduce best_bidder's budget after bid" do
  	pams_budget = @pam.budget
  	@pam.bid @guitar.id, 13.00
  	pams_budget -= 13.00
  	assert_equal pams_budget, @pam.reload.budget
  end

  test "should increase new bidder's blocked_budget" do
  	pams_blocked_budget = @pam.blocked_budget
  	@pam.bid @guitar.id, 13.00
  	pams_blocked_budget += 13.00
  	assert_equal pams_blocked_budget, @pam.reload.blocked_budget
  end

  test "should decrease previous best_bidder's blocked budget" do
  	matts_old_bid = auctions(:guitar).current_price
  	matts_blocked_budget = @matt.blocked_budget
  	@pam.bid @guitar.id, 13.00
  	matts_blocked_budget -= matts_old_bid
  	assert_equal matts_blocked_budget.to_f, @matt.reload.blocked_budget.to_f
  end

  test "should increase previous best_bidder's budget" do
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

  test "should not update new auction user" do
  	@pam.bid @guitar.id, 13.00
  	assert_equal @matt, auctions(:guitar).user
  end

  test "should update new auction's best_bidder" do
    @pam.bid @guitar.id, 13.00
    assert_equal @pam, auctions(:guitar).best_bidder
  end

	##################
	#### Tests for User.add_item item_name, start_price
	##################

  test "should successfully add an item for user" do
  	assert_not Item.find_by_name "pistol"
  	assert @matt.create_item_and_auction("pistol", "22.39")
    assert Item.find_by_name "pistol"
    assert_equal 22.39, Item.find_by_name("pistol").start_price
    assert @matt.errors.empty?
  end

  test "should add item with definded attributes" do
  	assert_not Item.find_by_name "pistol"
  	@matt.create_item_and_auction "pistol", 22.34
  	item = Item.find_by_name "pistol"
  	assert_equal "pistol", item.name
  	assert_equal 22.34, item.start_price
    assert @matt.errors.empty?
  end

  test "should create a new auction with defined specified fields" do
  	@matt.create_item_and_auction "rifle", "22.39"
  	auction = Auction.find_by_item_id Item.find_by_name("rifle").id
  	assert auction
  	assert_equal @matt, auction.user
  	assert_equal 22.39, auction.current_price
  	assert auction.is_active
    assert auction.best_bidder.nil?
    assert @matt.errors.empty?
  end

  test "should not create a new item when item_name is empty" do
    @matt.create_item_and_auction "", "22.39"
    assert !@matt.errors.empty?
    assert @matt.errors.full_messages.include? "Name can't be blank"
    auction = Auction.find_by_current_price 22.39
    assert auction.nil?
    item = Item.find_by_start_price 22.39
    assert item.nil?
  end

  test "should not create a new item when item_name is nil" do
    @matt.create_item_and_auction nil, "22.39"
    assert !@matt.errors.empty?
    assert @matt.errors.full_messages.include? "Name can't be blank"
    auction = Auction.find_by_current_price 22.39
    assert auction.nil?
    item = Item.find_by_start_price 22.39
    assert item.nil?
  end

  test "should not create a new item when start_price is invalid" do
    @matt.create_item_and_auction "blah", 1.123
    assert !@matt.errors.empty?
    auction = Auction.find_by_current_price 1.123
    assert auction.nil?
    item = Item.find_by_name "blah"
    assert item.nil?
  end

  test "should not create a new item when start_price is nil" do
    @matt.create_item_and_auction "blah", nil
    assert !@matt.errors.empty?
    auction = Auction.find_by_current_price nil
    assert auction.nil?
    item = Item.find_by_name "blah"
    assert item.nil?
  end

  test "should not create a new item when start_price is empty" do
    @matt.create_item_and_auction 11.23, ""
    assert !@matt.errors.empty?
    auction = Auction.find_by_current_price 11.23
    assert auction.nil?
    item = Item.find_by_start_price 11.23
    assert item.nil?
  end

  ##################
  #### Tests for Auction.snapshot
  ##################

  test "should return an array" do
    users = User.snapshot
    assert users.class == Array
  end

  test "User.shapshot should return id, budget, blocked_budget and owned_item_ids" do
    user = User.snapshot[0]
    assert user.include? "id"
    assert user.include? "budget"
    assert user.include? "blocked_budget"
    assert user.include? "owned_item_ids"
  end

  test "User.snapshot should not return created_at or updated_at" do
    users = User.snapshot
    users.each do |user|
      assert user["created_at"].nil?
      assert user["updated_at"].nil?
    end
   end
end
