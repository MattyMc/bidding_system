class Item < ActiveRecord::Base
	belongs_to :user
	has_one :auction

	validates :user_id, :name, :start_price, presence: true
	validates :start_price, numericality: { greater_than: 0 }
	validates_each :start_price, on: :create do |record, attr, value|
		v = value.to_f*100
		record.errors.add attr, "has too many decimal places" if v > v.to_i
	end

end
