class User < ActiveRecord::Base
	# Relationships -----------------------------------------------------------------------------
	has_many :items
	has_many :auctions
	has_many :best_bids, :class_name => 'Auction', :foreign_key => 'best_bidder_id'

	# Validations -------------------------------------------------------------------------------
	validates :id, :budget, :blocked_budget, presence: true
	validates_each :budget, :blocked_budget, on: :create do |record, attr, value|
		v = value.to_f*100
		record.errors.add attr, "has too many decimal places" if v > v.to_i
	end
	validates :budget, numericality: { greater_than_or_equal_to: 0 }
	validates :blocked_budget, numericality: { greater_than_or_equal_to: 0 }
	# TODO: Validate that each owned_item is unique

	# Errors ------------------------------------------------------------------------------------
	class InvalidBid < StandardError
	end

	# Serialization ------------------------------------------------------------------------------
	serialize :owned_item_ids, Array  # treat property as array



	# -------------------------------------------------------------------------------------------
	# Instance methods --------------------------------------------------------------------------
	# -------------------------------------------------------------------------------------------

	# TODO: Roll this into one transaction
	# TODO: Deal with situation where user creates multiple items with same name
	# Called from add_itme in user controller
	def create_item_and_auction item_name, start_price
		item = Item.create! user:self, name:item_name, start_price:start_price
		auction = Auction.create! item_id:item.id, user:item.user, current_price:item.start_price, is_active:true
		item
	end

	def bid item_id, amount
		# Errors occur instantiating BigDecimal object from a float
		amount = amount.to_s unless amount.class == String 
		bid_amount = BigDecimal.new amount

		# Note: Only exceptions will force a transaction rollback. Only use functions that will throw 
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
			unless @auction.best_bidder.nil?
				@former_highest_bidder = @auction.best_bidder == self ? self : @auction.best_bidder # avoid two instances
				@former_highest_bidder.budget += @auction.current_price
				@former_highest_bidder.blocked_budget -= @auction.current_price
				@former_highest_bidder.save! unless @former_highest_bidder == self # avoid transaction issues
			end
			# Update Auction with new bid
			@auction.best_bidder = self
			@auction.current_price = bid_amount
			@auction.save!

			# Save user
			self.save!
		end
	end

	# -------------------------------------------------------------------------------------------
	# Class methods -----------------------------------------------------------------------------
	# -------------------------------------------------------------------------------------------

	def self.snapshot
		users = []
		User.all.each do |u|
			users.push u.attributes.except("created_at", "updated_at")
		end
		users
	end


	# -------------------------------------------------------------------------------------------
	# Helper Methods  ---------------------------------------------------------------------------
	# -------------------------------------------------------------------------------------------
	# TODO: Make these private
	def bid_amount_above_current_price? current_price, bid_amount
		return true if bid_amount > current_price
		false
	end

	def sufficient_funds? bid_amount
		return true if  self.budget >= bid_amount 
		false
	end

	# JSON Helper Methods -----------------------------------------------------------------------
	# Will format JSON response in the following format
	# {
 	#    result : "success" | "error"
 	#    data : {}
 	#    error : nil | error_content
	# }
	# Where: error_content is a string of error messages
	#        data hash contains user information
	def response_json
		response = {}
		response[:result] = "success"
		response[:data] = self.attributes.except("created_at", "updated_at")
		response
	end

	def response_json_add_item item_id
		response = {}
		response[:result] = "success"
		response[:data] = item_id
		response
	end

	def response_status
		return :bad_request if !self.errors.empty? # 400 
		return :ok if self.errors.empty?
	end

end
