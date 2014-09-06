require 'test_helper'

class AuctionControllerTest < ActionController::TestCase
  # Since we are using transactional fixtures
  self.use_transactional_fixtures = false 

  def setup
  	@guitar_auction = auctions(:guitar)
  	@closed_auction = auctions(:closed_auction)
  	@matt = users(:matt)
  end

  def json_response
    ActiveSupport::JSON.decode @response.body
  end

  test "should successfully end auction" do
    get :finish, {item_id:@guitar_auction.item.id}
    assert_response :success
  end

  test "should respond with success" do
    get :finish, {item_id:@guitar_auction.item.id}
    assert_equal "success", json_response["result"]
  end

  test "should respond with appropriate hash when auction is successfully ended" do
    get :finish, {item_id:@guitar_auction.item.id}
    # assert_equal @guitar_auction.best_bidder_id, json_response["data"]["winner_id"]
    assert_equal @guitar_auction.current_price.to_s, json_response["data"]["price"].to_s
  end

  test "should respond with appropriate status when auction is unsuccessfully ended" do
    get :finish, {item_id:@closed_auction.item.id}
    assert_response :bad_request
    assert_nil json_response["data"]
  end

  test "should respond with appropriate error message when auction is unsuccessfully ended" do
    get :finish, {item_id:@closed_auction.item.id}
    assert_equal json_response["result"], "error"
    assert json_response["error"].include? "auction has already closed"
  end

  test "should return an error if no auction found for item_id" do
    get :finish, {item_id:1231}
    assert_response :bad_request
    assert_equal json_response["result"], "error"
    assert_nil json_response["data"]
  end

end
