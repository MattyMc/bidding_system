require 'test_helper'

class UserControllerTest < ActionController::TestCase
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
  
  # Tests for add_user
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
    assert_equal json_response["result"], "fail"
    assert_nil json_response["data"]
    assert_not_nil json_response["error"]
  end

  test "should not add_user if missing budget" do
    get :add_user, {user_id: 25}
    assert_response :bad_request
    assert_equal json_response["result"], "fail"
  end

  test "should not add_user if negative budget" do
    get :add_user, {user_id: 25, budget: -10}
    assert_response :bad_request
    assert_equal json_response["result"], "fail"
  end

  # Tests for add_item
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
    assert_equal json_response["result"], "fail"
    assert_nil json_response["data"]
    assert_not_nil json_response["error"]
  end

  test "should not add new item without name" do
    get :add_item, {user_id:@pam.id, start_price:12.99}
    assert_response :bad_request
    assert_equal json_response["result"], "fail"
    assert_nil json_response["data"]
    assert_not_nil json_response["error"]
  end

  test "should not add new item without start_price" do
    get :add_item, {user_id:@pam.id, item_name:"harmonica"}
    assert_response :bad_request
    assert_equal json_response["result"], "fail"
    assert_nil json_response["data"]
    assert_not_nil json_response["error"]
  end
  # Tests for bid
  # test "should get bid" do
  #   get :bid
  #   assert_response :success
  # end

end
