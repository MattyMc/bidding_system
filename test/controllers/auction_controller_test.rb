require 'test_helper'

class AuctionControllerTest < ActionController::TestCase
  test "should get finish" do
    get :finish
    assert_response :success
  end

end
