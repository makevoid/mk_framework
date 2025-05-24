# frozen_string_literal: true

class CartsUpdateController < MK::Controller
  route do |r|
    session_id = r.params.fetch('id')
    
    # Check if this is an item update or quantity update
    if r.params.key?('item_id')
      # Update specific cart item quantity
      item_id = r.params.fetch('item_id')
      quantity = r.params.fetch('quantity').to_i
      
      r.halt(422, { error: "Quantity must be positive" }) if quantity <= 0
      
      cart = Cart.find(session_id: session_id)
      r.halt(404, { error: "Cart not found" }) if cart.nil?
      
      item = cart.cart_items_dataset.where(id: item_id).first
      r.halt(404, { error: "Item not found in cart" }) if item.nil?
      
      product = item.product
      r.halt(422, { error: "Insufficient stock" }) if product.stock < quantity
      
      item.update(quantity: quantity)
      
      cart.reload
    else
      # General cart update (could be extended for other cart properties)
      cart = Cart.find(session_id: session_id)
      r.halt(404, { error: "Cart not found" }) if cart.nil?
      
      cart
    end
  end
end