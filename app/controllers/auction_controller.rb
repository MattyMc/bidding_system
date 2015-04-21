class AuctionController < ApplicationController
  
  def finish
  	auction = Auction.find_by_item_id! params["item_id"]
  	auction.finish
  	
	render json:{result: "success", data: auction.success_response_hash}  
  rescue StandardError => e
    render json:{result: "error", error: e.message}, status: :bad_request
  end

end
