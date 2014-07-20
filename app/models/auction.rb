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
			# Eliminate race conditions by using :repeatable_read isolation level
			Auction.transaction(isolation: :repeatable_read) do
				
				# Update the winning user 
				self.best_bidder.blocked_budget -= self.current_price.to_f
				self.best_bidder.owned_item_ids.push self.item.id
				self.best_bidder.save!

				self.update! is_active: false
			end
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


	def self.snapshot
		auctions = []
		Auction.all.each do |a|
			auctions.push a.attributes.except("created_at", "updated_at") 
		end
		auctions
	end
end
