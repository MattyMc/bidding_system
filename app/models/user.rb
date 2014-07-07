class User < ActiveRecord::Base
	has_many :items
	has_many :auctions

	validates :budget, :blocked_budget, presence: true
	validates :budget, numericality: { greater_than_or_equal_to: 0 }
	validates :blocked_budget, numericality: { greater_than_or_equal_to: 0 }
end
