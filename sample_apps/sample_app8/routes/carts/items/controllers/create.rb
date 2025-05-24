# frozen_string_literal: true

class CartsItemsCreateController < MK::Controller
  route do |r|
    session_id = r.params.fetch('id')
    product_id = r.params.fetch('product_id')
    quantity = (r.params['quantity'] || 1).to_i
    
    r.halt(422, { error: "Quantity must be positive" }) if quantity <= 0
    
    # Find or create cart
    cart = Cart.find(session_id: session_id) || Cart.create(session_id: session_id)
    
    # Find product
    product = Product[product_id]
    r.halt(404, { error: "Product not found" }) if product.nil?
    r.halt(422, { error: "Product not available" }) unless product.available?
    r.halt(422, { error: "Insufficient stock" }) if product.stock < quantity
    
    # Add item to cart
    cart.add_item(product, quantity)
    
    cart
  end
end