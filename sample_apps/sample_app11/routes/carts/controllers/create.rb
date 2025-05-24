# frozen_string_literal: true

class CartsCreateController < MK::Controller
  route do |r|
    user_id = r.params.fetch('user_id')
    product_id = r.params.fetch('product_id')
    quantity = r.params.fetch('quantity').to_i
    
    user = User[user_id]
    r.halt(404, { error: "User not found" }.to_json) unless user
    
    product = Product[product_id]
    r.halt(404, { error: "Product not found" }.to_json) unless product
    
    # Check if product is active
    r.halt(400, { error: "Product is not available" }.to_json) unless product.active
    
    # Check stock availability
    if product.stock_quantity < quantity
      r.halt(400, { 
        error: "Insufficient stock",
        available: product.stock_quantity
      }.to_json)
    end
    
    # Check if item already exists in cart
    existing_item = CartItem.where(user_id: user_id, product_id: product_id).first
    
    if existing_item
      # Update quantity
      new_quantity = existing_item.quantity + quantity
      if product.stock_quantity < new_quantity
        r.halt(400, { 
          error: "Insufficient stock for total quantity",
          available: product.stock_quantity,
          current_in_cart: existing_item.quantity
        }.to_json)
      end
      existing_item.quantity = new_quantity
      existing_item.save
      existing_item
    else
      # Create new cart item
      cart_item = CartItem.new(
        user_id: user_id,
        product_id: product_id,
        quantity: quantity
      )
      
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
end