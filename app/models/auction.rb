class Auction < ActiveRecord::Base
	
	# Relationships -----------------------------------------------------------------------------
	belongs_to :item
	belongs_to :user
	belongs_to :best_bidder, :class_name => 'User', :foreign_key => 'best_bidder_id'

	# Validations -------------------------------------------------------------------------------
	validates_presence_of :user_id, :item_id, :current_price
	validates_inclusion_of :is_active, :in => [true, false] 
	validates :current_price, numericality: { greater_than_or_equal_to: 0 }
	
	# Errors -------------------------------------------------------------------------------------
	class AuctionError < StandardError
	end



	# -------------------------------------------------------------------------------------------
	# Instance methods --------------------------------------------------------------------------
	# -------------------------------------------------------------------------------------------
	def finish
		raise AuctionError, "auction has already closed" unless self.is_active

		# Account for race conditions by using :repeatable_read isolation level
		Auction.transaction(isolation: :repeatable_read) do
			
			# Update the winning user 
			unless self.best_bidder.nil?
				self.best_bidder.blocked_budget -= self.current_price
				self.best_bidder.owned_item_ids.push self.item.id
				self.best_bidder.save!
			else
				# Give the item back to the person who added it
				# TODO: WRITE A TEST FOR THIS
				user_who_added_item = self.item.user
				user_who_added_item.owned_item_ids.push self.item.id
				user_who_added_item.save!
			end

			self.update! is_active: false
		end
	end




	# -------------------------------------------------------------------------------------------
	# Helper Methods for JSON response ----------------------------------------------------------
	# -------------------------------------------------------------------------------------------

	def success_response_hash
		data = {}
		data[:winner_id] = self.best_bidder_id
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
