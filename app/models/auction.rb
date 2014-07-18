class Auction < ActiveRecord::Base

	belongs_to :item
	belongs_to :user

	validates_presence_of :user_id, :item_id, :current_price
	validates_inclusion_of :is_active, :in => [true, false] 
	validates :current_price, numericality: { greater_than_or_equal_to: 0 }

	def finish
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
end
