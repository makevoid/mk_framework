# frozen_string_literal: true

class CartsDeleteController < MK::Controller
  route do |r|
    user_id = r.params.fetch('user_id')
    cart_item_id = r.params.fetch('id')
    
    user = User[user_id]
    r.halt(404, { error: "User not found" }.to_json) unless user
    
    cart_item = CartItem.where(id: cart_item_id, user_id: user_id).first
    r.halt(404, { error: "Cart item not found" }.to_json) unless cart_item
    
    cart_item.delete
    { id: cart_item_id.to_i, user_id: user_id.to_i }
  end
end