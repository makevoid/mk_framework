# frozen_string_literal: true

class CartsDeleteController < MK::Controller
  route do |r|
    session_id = r.params.fetch('id')
    
    cart = Cart.find(session_id: session_id)
    r.halt(404, { error: "Cart not found" }) if cart.nil?
    
    if r.params.key?('item_id')
      # Remove specific item from cart
      item_id = r.params.fetch('item_id')
      
      item = cart.cart_items_dataset.where(id: item_id).first
      r.halt(404, { error: "Item not found in cart" }) if item.nil?
      
      item.destroy
      
      cart.reload
    elsif r.params['action'] == 'clear'
      # Clear entire cart
      cart.clear!
      cart.reload
    else
      # Default: clear entire cart
      cart.clear!
      cart.reload
    end
  end
end