# frozen_string_literal: true

class CartRemoveItemController < MK::Controller
  route do |r|
    session_id = r.params.fetch('id')
    item_id = r.params.fetch('item_id')
    
    cart = Cart.find(session_id: session_id)
    r.halt(404, { error: "Cart not found" }) if cart.nil?
    
    item = cart.cart_items_dataset.where(id: item_id).first
    r.halt(404, { error: "Item not found in cart" }) if item.nil?
    
    item.destroy
    
    cart.reload
  end
end