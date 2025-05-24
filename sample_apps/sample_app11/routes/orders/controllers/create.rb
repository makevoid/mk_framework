# frozen_string_literal: true

class OrdersCreateController < MK::Controller
  route do |r|
    user_id = r.params.fetch('user_id')
    shipping_address = r.params.fetch('shipping_address')
    
    user = User[user_id]
    r.halt(404, { error: "User not found" }.to_json) unless user
    
    # Check if user has items in cart
    cart_items = user.cart_items
    if cart_items.empty?
      r.halt(400, { error: "Cart is empty" }.to_json)
    end
    
    # Check stock availability for all items
    insufficient_stock = []
    cart_items.each do |item|
      unless item.can_fulfill?
        insufficient_stock << {
          product_id: item.product_id,
          product_name: item.product.name,
          requested: item.quantity,
          available: item.product.stock_quantity
        }
      end
    end
    
    unless insufficient_stock.empty?
      r.halt(400, {
        error: "Insufficient stock for some items",
        details: insufficient_stock
      }.to_json)
    end
    
    # Calculate total amount
    total_amount = cart_items.sum { |item| item.quantity * item.product.price }
    
    # Create order
    order = Order.new(
      user_id: user_id,
      total_amount: total_amount,
      shipping_address: shipping_address,
      status: 'pending'
    )
    
    unless order.valid?
      r.halt(422, {
        error: "Validation failed",
        details: order.errors
      }.to_json)
    end
    
    order.save
    
    # Create order items and update stock
    cart_items.each do |cart_item|
      product = cart_item.product
      
      OrderItem.create(
        order_id: order.id,
        product_id: product.id,
        quantity: cart_item.quantity,
        unit_price: product.price,
        total_price: cart_item.quantity * product.price
      )
      
      # Update stock quantity
      product.update(stock_quantity: product.stock_quantity - cart_item.quantity)
      
      # Remove from cart
      cart_item.delete
    end
    
    order
  end
end