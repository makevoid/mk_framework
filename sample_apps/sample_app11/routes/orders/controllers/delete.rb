# frozen_string_literal: true

class OrdersDeleteController < MK::Controller
  route do |r|
    order_id = r.params.fetch('id')
    order = Order[order_id]
    
    r.halt(404, { error: "Order not found" }.to_json) unless order
    
    # Only allow deletion of cancelled orders or pending orders
    unless %w[cancelled pending].include?(order.status)
      r.halt(400, { 
        error: "Can only delete cancelled or pending orders" 
      }.to_json)
    end
    
    # Restore stock if order was pending
    if order.status == 'pending'
      order.order_items.each do |item|
        product = item.product
        product.update(stock_quantity: product.stock_quantity + item.quantity)
      end
    end
    
    # Delete order items first
    order.order_items.each(&:delete)
    
    order.delete
    { id: order_id.to_i }
  end
end