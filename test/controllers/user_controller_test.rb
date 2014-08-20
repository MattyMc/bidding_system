require 'test_helper'

class UserControllerTest < ActionController::TestCase
  # Since we are using transactional fixtures
  self.use_transactional_fixtures = false 

  def setup
    @matt = users(:matt)
    @pam = users(:pam)
    @jay = users(:jay)
    @olivia = users(:olivia)

    @teddy_bear = items(:teddy_bear) # This auction is closed
    @guitar = items(:guitar) # This auction is open, price is $12.99 (matt)
    @hockey_stick = items(:hockey_stick)
  end

  # Easily test response parameters using json_response['result']
  def json_response
    ActiveSupport::JSON.decode @response.body
  end
  
  ##################
  #### Tests for add_user
  ##################
  test "should get add_user" do
    get :add_user, {user_id: 25, budget: 0}
    assert_response :success
    assert_equal json_response["result"], "success"
    assert_nil json_response["error"]
    assert_not_nil json_response["data"]
  end

  test "should not add_user if missing user_id" do
    get :add_user, {budget: 0}
    assert_response :bad_request
    assert_equal json_response["result"], "error"
    assert_nil json_response["data"]
    assert_not_nil json_response["error"]
  end

  test "should not add_user if missing budget" do
    get :add_user, {user_id: 25}
    assert_response :bad_request
    assert_equal json_response["result"], "error"
  end

  test "should not add_user if negative budget" do
    get :add_user, {user_id: 25, budget: -10}
    assert_response :bad_request
    assert_equal json_response["result"], "error"
  end

  ##################
  #### Tests for add_item
  ##################
  test "should add new item using add_item" do
    get :add_item, {user_id: @pam.id, item_name:"harmonicaaaa", start_price:12.99}
    assert_response :success
    assert_equal json_response["result"], "success"
    assert_not_nil json_response["data"]
    assert_equal json_response["data"], Item.find_by_name("harmonicaaaa").id
    assert_nil json_response["error"]
  end

  test "should not add new item without user" do
    get :add_item, {item_name:"harmonica", start_price:12.99}
    assert_response :bad_request
    assert_equal json_response["result"], "error"
    assert_nil json_response["data"]
    assert_not_nil json_response["error"]
  end

  test "should not add new item without name" do
    get :add_item, {user_id:@pam.id, start_price:12.99}
    assert_response :bad_request
    assert_equal json_response["result"], "error"
    assert_nil json_response["data"]
    assert_not_nil json_response["error"]
  end

  test "should not add new item without start_price" do
    get :add_item, {user_id:@pam.id, item_name:"harmonica"}
    assert_response :bad_request
    assert_equal json_response["result"], "error"
    assert_nil json_response["data"]
    assert_not_nil json_response["error"]
  end

  ##################
  #### Tests for bid
  ##################
  test "should raise exception if no auction found" do
    get :bid, {user_id:@matt.id, item_id:202, amount:2}
    assert_response :bad_request
    assert_not_nil json_response["error"]
    assert_equal json_response["result"], "error"
  end

  test "should return insufficient funds if user's budget is insufficient" do
    get :bid, {user_id:@pam.id, item_id:@guitar.id, amount:30.00}
    assert_response :bad_request
    assert_equal json_response["error"], "insufficient funds"
    assert_equal json_response["result"], "error"
  end

  test "should not allow bid if auction is closed" do 
    get :bid, {user_id:@pam.id, item_id:@teddy_bear.id, amount:25}
    assert_response :bad_request
    assert_equal json_response["error"], "auction is closed"
    assert_equal json_response["result"], "error"
  end

  test "should raise error if bid amount is lower than current auction price" do
    get :bid, {user_id:@pam.id, item_id:@guitar.id, amount:12.98}
    assert_equal json_response["error"], "invalid amount"
    assert_response :bad_request
    assert_equal json_response["result"], "error"
  end

  # Pam bids on Matt's guitar
  test "should accept higher bid" do 
    get :bid, {user_id:@pam.id, item_id:@guitar.id, amount:13.00}
    assert_equal json_response["result"], "success"
    assert_nil json_response["error"]
  end

end
