class UserController < ApplicationController
  before_action :find_user, only: [:add_item]

  # QUESTION: Is this worth moving to the model? 
  # QUESTION: Does a method this simple necessitate comments/documentation?
  def add_user
    user = User.create id:params["user_id"], budget:params["budget"], blocked_budget:0
    render json:user.response_json, status: user.response_status
  end

  # TODO: FIX RESPONSE OF THIS FUNCTION TO FIT EXAMPLE
  # TODO: MOVE EVERYTHING BELOW TO MODEL. REFACTOR MODEL
  def add_item
    @user.create_item_and_auction params["item_name"], params["start_price"]
	  render json:@user.response_json_add_item(params["item_name"]), status: @user.response_status
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

  def find_user
  	@user = User.find_by_id params["user_id"]
    if @user.nil? 
      response = {result: "fail", error: "could not find user"}
      render json:response.to_json, status: :bad_request
    end 
  end
end
