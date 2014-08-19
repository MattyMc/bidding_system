class UserController < ApplicationController
  before_action :form_response_map

  # QUESTION: Is this worth moving to the model? 
  # QUESTION: Does a method this simple necessitate comments/documentation?
  def add_user
    user = User.create id:params["user_id"], budget:params["budget"], blocked_budget:0
    render json: user.response_json, status: user.response_status
  end

  def add_item
  	logger.warn user_params
  	@item = Item.new(user_id: params["user_id"], item_name: params["item_name"], start_price: params["start_price"])
  	response_map = {}

  	if @item.new_record?
  		@item.save
		Auction.create! item_id: @item.id, user: @item.user, current_price: @item.start_price, is_active:true

		response_map[:result] = "success"
		response_map[:data] = @item.id
	else
		response_map[:result] = "error"
	end

	render json: response_map.to_json
  end

  def bid
  	@user = User.find params[:user_id]

  	response = @user.bid params[:item_id], params[:amount]
    
  	if response.class == "String"
  		@response_map[:result] = "error"
  		@response_map[:error] = response
  	end
  	
  	render json: @response_map.to_json
  end

  private 

  def user_params
  	params.permit!
  end

  def form_response_map
  	@response_map = {}
  	@response_map[:result] = "success"
  end
end
