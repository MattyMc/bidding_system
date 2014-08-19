class User < ActiveRecord::Base
	has_many :items
	has_many :auctions
	has_many :best_bids, :class_name => 'Auction', :foreign_key => 'best_bidder_id'

	validates :id, :budget, :blocked_budget, presence: true
	validates_each :budget, :blocked_budget, on: :create do |record, attr, value|
		v = value.to_f*100
		record.errors.add attr, "has too many decimal places" if v > v.to_i
	end
	validates :budget, numericality: { greater_than_or_equal_to: 0 }
	validates :blocked_budget, numericality: { greater_than_or_equal_to: 0 }

	serialize :owned_item_ids, Array

	class InvalidBid < StandardError
	end

	# Adds a new item and corresponding auction to the database
	def add_item item_name, start_price
		# Errors occur instantiating BigDecimal object from a float
		start_price = start_price.to_s unless start_price.class == String 
		start_price = BigDecimal.new start_price

  		@item = Item.create! user:self, name:item_name, start_price:start_price
  	
		Auction.create! item: @item, user: self, current_price: @item.start_price, is_active:true, best_bidder: nil
	end

	# Method returns true if bid is accepted, false if bid is not accepted (or raises exception)
	# Errors are stored in class instance (self.errors[:error])
	def bid item_id, amount
		# Errors occur instantiating BigDecimal object from a float
		amount = amount.to_s unless amount.class == String 
		bid_amount = BigDecimal.new amount

		# Note: Only exceptions will forced a transaction rollback. Only use functions that will throw 
		# exceptions if they fail (such as those ending in '!'), and write additional exceptions where required. 
		
		
		User.transaction(isolation: :repeatable_read) do

			# Check whether auction is open. Using 'banged' version of find since it will throw an exception
			@auction = Auction.includes(:user).find_by_item_id! item_id
			raise InvalidBid, "auction is closed" unless @auction.is_active?
			
			# Check whether users funds are too low or bid is too low
			raise InvalidBid, "insufficient funds" unless self.sufficient_funds? bid_amount
			raise InvalidBid, "invalid amount" unless self.bid_amount_above_current_price? @auction.current_price, bid_amount

			# Decrease user's budget & increase blocked_budget
			self.budget -= bid_amount
			self.blocked_budget += bid_amount

			# Restore money to the former highest bidder
			@former_highest_bidder = @auction.best_bidder == self ? self : @auction.best_bidder # avoid two instances
			@former_highest_bidder.budget += @auction.current_price
			@former_highest_bidder.blocked_budget -= @auction.current_price
			@former_highest_bidder.save! unless @former_highest_bidder == self # avoid transaction issues

			# Update Auction with new bid
			@auction.best_bidder = self
			@auction.current_price = bid_amount
			@auction.save!

			# Save user
			self.save!
			return true
		end
		return false
	end

	def self.snapshot
		users = []
		User.all.each do |u|
			users.push u.attributes.except("created_at", "updated_at")
		end
		users
	end

	# Will format JSON response in the following format
	# {
 	#    result : "success" | "fail"
 	#    data : {}
 	#    error : nil | error_content
	# }
	# Where: error_content is a string of error messages
	#        data hash contains user information
	def response_json
		response = {}
		if self.errors.empty?
			response[:result] = "success"
			response[:data] = self.attributes.except("created_at", "updated_at")
		else
			response[:result] = "error"
			response[:error] = self.errors.full_messages.join ", "
		end
		response.to_json
	end

	def response_status
		return :bad_request if !self.errors.empty? # 400 
		return :ok if self.errors.empty?
	end

	def bid_amount_above_current_price? current_price, bid_amount
		return true if bid_amount > current_price
		false
	end

	def sufficient_funds? bid_amount
		return true if  self.budget >= bid_amount 
		false
	end
end
