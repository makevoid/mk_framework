# frozen_string_literal: true

class CheckoutsCreateController < MK::Controller
  route do |r|
    session_id = r.params.fetch('session_id')
    
    cart = Cart.find(session_id: session_id)
    r.halt(404, { error: "Cart not found" }) if cart.nil?
    r.halt(422, { error: "Cart is empty" }) if cart.empty?
    
    # Validate stock availability
    cart.cart_items.each do |item|
      product = item.product
      if product.stock < item.quantity
        r.halt(422, { 
          error: "Insufficient stock", 
          product: product.name,
          available: product.stock,
          requested: item.quantity
        })
      end
    end
    
    # Create order
    order = nil
    DB.transaction do
      order = Order.create(
        cart_id: cart.id,
        total: cart.total,
        customer_email: r.params.fetch('customer_email'),
        customer_name: r.params.fetch('customer_name'),
        shipping_address: r.params.fetch('shipping_address'),
        payment_method: r.params['payment_method'],
        status: 'pending'
      )
      
      # Reduce stock for each item
      cart.cart_items.each do |item|
        item.product.reduce_stock!(item.quantity)
      end
      
      # Clear the cart
      cart.clear!
    end
    
    order
  end
end