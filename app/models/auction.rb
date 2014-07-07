class Auction < ActiveRecord::Base
	belongs_to :item
	belongs_to :user

	validates :user_id, :item_id, :current_price, :is_active, presence: true
	validates :current_price, numericality: { greater_than_or_equal_to: 0 }
end
