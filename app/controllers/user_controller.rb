class UserController < ApplicationController
  before_action :form_response_map

  def add_user
  	logger.warn user_params
  	@user = User.where(:id => params["user_id"]).first_or_initialize
  	response_map = {}

  	if @user.new_record?
  		@user.budget = params["budget"]
  		@user.blocked_budget = 0
		@user.save
		response_map[:result] = "success"
	else
		logger.warn @user.errors.messages
		response_map[:result] = "error"
		response_map[:error] = "user exists"
	end

	render json: response_map.to_json
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

  	response = @user.bid params[:item_id] params[:amount]
    
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
