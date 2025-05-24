# frozen_string_literal: true

class OrdersUpdateController < MK::Controller
  route do |r|
    order_id = r.params.fetch('id')
    order = Order[order_id]
    
    r.halt(404, { error: "Order not found" }.to_json) unless order
    
    # Only allow status updates for now
    new_status = r.params['status']
    
    if new_status
      # Validate status transition
      case new_status
      when 'confirmed'
        unless order.status == 'pending'
          r.halt(400, { error: "Can only confirm pending orders" }.to_json)
        end
      when 'processing'
        unless order.status == 'confirmed'
          r.halt(400, { error: "Can only process confirmed orders" }.to_json)
        end
      when 'shipped'
        unless order.can_ship?
          r.halt(400, { error: "Order cannot be shipped" }.to_json)
        end
      when 'delivered'
        unless order.status == 'shipped'
          r.halt(400, { error: "Can only deliver shipped orders" }.to_json)
        end
      when 'cancelled'
        unless order.can_cancel?
          r.halt(400, { error: "Order cannot be cancelled" }.to_json)
        end
        
        # Restore stock when cancelling
        if order.can_cancel?
          order.order_items.each do |item|
            product = item.product
            product.update(stock_quantity: product.stock_quantity + item.quantity)
          end
        end
      else
        r.halt(400, { error: "Invalid status" }.to_json)
      end
      
      order.status = new_status
    end
    
    # Update shipping address if provided
    if r.params['shipping_address']
      order.shipping_address = r.params['shipping_address']
    end
    
    unless order.valid?
      r.halt(422, {
        error: "Validation failed",
        details: order.errors
      }.to_json)
    end
    
    order.save
    order
  end
end