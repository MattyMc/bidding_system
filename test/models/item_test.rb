require 'test_helper'

class ItemTest < ActiveSupport::TestCase
def setup
	@matt = users(:matt)
	@pam = users(:pam)
	@jay = users(:jay)
	@olivia = users(:olivia)

	@teddy_bear = items(:teddy_bear) # This auction is closed
	@guitar = items(:guitar) # This auction is open, price is $12.99 (matt)
	@hockey_stick = items(:hockey_stick)
end

  test "should create new item" do
  	item = Item.new name:"anything", start_price:12.50, user_id:@pam.id 
    assert item.save
  end

  test "should not create new item with user" do
  	item = Item.new name:"anything", start_price:12.50, user_id:nil
    assert_not item.save
  end

  test "should not create new item without name" do
	item = Item.new start_price:12.50, user_id:@pam.id 
    assert_not item.save
  end

  test "should not create new item without start_price" do
	item = Item.new name:"anything", user_id:@pam.id 
    assert_not item.save
  end
end
