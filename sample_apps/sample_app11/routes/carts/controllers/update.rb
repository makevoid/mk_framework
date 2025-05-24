# frozen_string_literal: true

class CartsUpdateController < MK::Controller
  route do |r|
    user_id = r.params.fetch('user_id')
    cart_item_id = r.params.fetch('id')
    quantity = r.params.fetch('quantity').to_i
    
    user = User[user_id]
    r.halt(404, { error: "User not found" }.to_json) unless user
    
    cart_item = CartItem.where(id: cart_item_id, user_id: user_id).first
    r.halt(404, { error: "Cart item not found" }.to_json) unless cart_item
    
    product = cart_item.product
    
    # Check stock availability
    if product.stock_quantity < quantity
      r.halt(400, { 
        error: "Insufficient stock",
        available: product.stock_quantity
      }.to_json)
    end
    
    cart_item.quantity = quantity
    
    unless cart_item.valid?
      r.halt(422, {
        error: "Validation failed",
        details: cart_item.errors
      }.to_json)
    end
    
    cart_item.save
    cart_item
  end
end