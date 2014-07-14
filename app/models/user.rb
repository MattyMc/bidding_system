class User < ActiveRecord::Base
	has_many :items
	has_many :auctions

	validates :budget, :blocked_budget, presence: true
	validates :budget, numericality: { greater_than_or_equal_to: 0 }
	validates :blocked_budget, numericality: { greater_than_or_equal_to: 0 }

	class NoAuctionForItem < StandardError
	end


	# Method returns true if bid is accepted, false if bid is not accepted
	# Errors are stored in class instance (self.errors[:error])
	def bid item_id, amount
		# Errors occur instantiating BigDecimal object from a float
		amount = amount.to_s unless amount.class == String 
		
		# Note: Only exceptions will forced a transaction rollback. Only use functions that will throw 
		# exceptions if they fail (such as those ending in '!'), and write additional exceptions where required. 
		# User.transaction do

			# Check whether auction is open. Using 'banged' version of find since it will throw an exception
			@auction = Auction.includes(:user).find_by_item_id! item_id
			if !@auction.is_active 
				self.errors[:error] << "auction is closed"
				return false
			end

			# @auction.is_active = false
			# @auction.save!
			# @auction.reload

			# Check whether users funds are too low or bid is too low
			bid_amount = BigDecimal.new amount, 2
			return false unless self.sufficient_funds? bid_amount
			return false unless self.bid_amount_above_current_price? @auction.current_price, bid_amount

			# Decrease user's budget & increase blocked_budget
			self.budget -= bid_amount
			self.blocked_budget += bid_amount

			# Restore money to the former highest bidder
			@former_highest_bidder = @auction.user
			@former_highest_bidder.budget += @auction.current_price
			@former_highest_bidder.blocked_budget -= @auction.current_price
			@former_highest_bidder.save!

			# Update Auction with new bid
			@auction.user = self
			@auction.current_price = bid_amount
			@auction.save!

			# Save user
			self.save!
		# end
	end

	

	def bid_amount_above_current_price? current_price, bid_amount
		return true if bid_amount > current_price

		self.errors[:error] << "invalid amount"
		false
	end

	def sufficient_funds? bid_amount
		return true if  self.budget >= bid_amount 
		
		self.errors[:error] << "insufficient funds"
		false
	end
end
