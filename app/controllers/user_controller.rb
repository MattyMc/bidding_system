class UserController < ApplicationController
  before_action :find_user, only: [:add_item, :bid]

  def add_user
    user = User.create! id:params["user_id"], budget:params["budget"], blocked_budget:0
    render json:user.response_json
  rescue StandardError => e
    render json:{result: "error", error: e.message}, status: :bad_request
  end

  def add_item
    item = @user.create_item_and_auction params["item_name"], params["start_price"]
	  render json:@user.response_json_add_item(item.id)
  rescue StandardError => e
    render json:{result: "error", error: e.message}, status: :bad_request
  end

  def bid
  	@user.bid params[:item_id], params[:amount]
  	render json:{result: "success"}
  rescue StandardError => e
    render json:{result: "error", error: e.message}, status: :bad_request
  end

  # TODO: Find a better place for this
  def snapshot
    render json:{result:"success", data:{auctions: Auction.snapshot, users:User.snapshot}}, response: :success
  rescue StandardError => e
    render json:{result: "error", error:e.message}, status: :bad_request
  end  

  private 

  def find_user
  	@user = User.find params["user_id"]
  rescue StandardError => e
    render json:{result: "error", error: e.message}, status: :bad_request
  end

end
