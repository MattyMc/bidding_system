class User < ActiveRecord::Base
	has_many :items
	has_many :auctions
end
