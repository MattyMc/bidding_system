require 'test_helper'

class UserControllerTest < ActionController::TestCase
  # Tests for add_user
  test "should get add_user" do
    get :add_user, {user_id: 25, budget: 0}
    assert_response :success
  end

  test "should not add_user if missing user_id" do
    get :add_user, {budget: 0}
    assert_response :bad_request
  end

  test "should not add_user if missing budget" do
    get :add_user, {user_id: 25}
    assert_response :bad_request
  end

  test "should not add_user if negative budget" do
    get :add_user, {user_id: 25, budget: -10}
    assert_response :bad_request
  end

  # Tests for add_item
  # test "should get add_item" do
  #   get :add_item
  #   assert_response :success
  # end


  # Tests for bid
  # test "should get bid" do
  #   get :bid
  #   assert_response :success
  # end

end
