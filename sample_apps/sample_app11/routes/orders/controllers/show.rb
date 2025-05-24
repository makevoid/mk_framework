# frozen_string_literal: true

class OrdersShowController < MK::Controller
  route do |r|
    order_id = r.params.fetch('id')
    order = Order.join(:users, id: :user_id)
                 .select_all(:orders)
                 .select_append(:users__first_name___user_first_name)
                 .select_append(:users__last_name___user_last_name)
                 .select_append(:users__email___user_email)
                 .where(orders__id: order_id)
                 .first
    
    r.halt(404, { error: "Order not found" }.to_json) unless order
    
    order_items = order.order_items
                       .join(:products, id: :product_id)
                       .select_all(:order_items)
                       .select_append(:products__name___product_name)
                       .select_append(:products__sku___product_sku)
                       .order(:order_items__created_at)
    
    order.to_hash.merge(
      user_name: "#{order[:user_first_name]} #{order[:user_last_name]}",
      user_email: order[:user_email],
      items_count: order.items_count,
      formatted_total: order.formatted_total,
      can_cancel: order.can_cancel?,
      can_ship: order.can_ship?,
      order_items: order_items.all.map do |item|
        item.to_hash.merge(
          product_name: item[:product_name],
          product_sku: item[:product_sku]
        )
      end
    )
  end
end