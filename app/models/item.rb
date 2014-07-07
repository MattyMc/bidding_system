class Item < ActiveRecord::Base
	belongs_to :user
	has_one :auction

	validates :user_id, :item_name, :start_price, presence: true
	validates :start_price, numericality: { greater_than: 0 }

end
