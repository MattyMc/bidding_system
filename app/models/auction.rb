class Auction < ActiveRecord::Base
	belongs_to :item
	belongs_to :user
	belongs_to :best_bidder, :class_name => 'User', :foreign_key => 'best_bidder_id'

	validates_presence_of :user_id, :item_id, :current_price
	validates_inclusion_of :is_active, :in => [true, false] 
	validates :current_price, numericality: { greater_than_or_equal_to: 0 }

	def finish
		# TODO: Add the item to the user's owned_items array
		if self.is_active
			self.update! is_active: false
		else
			self.errors.add :error, "auction is already closed"
			return false
		end
	end

	def auction_data
		return false if self.is_active
		data = {}
		data[:winner_id] = self.user_id
		data[:price] = self.current_price
		return data
	end


	# def self.snapshot
	# end
end
