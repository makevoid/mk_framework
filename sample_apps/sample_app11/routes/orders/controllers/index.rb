# frozen_string_literal: true

class OrdersIndexController < MK::Controller
  route do |r|
    orders = Order.join(:users, id: :user_id)
                  .select_all(:orders)
                  .select_append(:users__first_name___user_first_name)
                  .select_append(:users__last_name___user_last_name)
                  .order(:orders__created_at)
                  .reverse
    
    # Filter by user if specified
    if r.params['user_id']
      orders = orders.where(orders__user_id: r.params['user_id'])
    end
    
    # Filter by status if specified
    if r.params['status']
      orders = orders.where(orders__status: r.params['status'])
    end
    
    orders.all.map do |order|
      order.to_hash.merge(
        user_name: "#{order[:user_first_name]} #{order[:user_last_name]}",
        items_count: order.items_count,
        formatted_total: order.formatted_total,
        can_cancel: order.can_cancel?,
        can_ship: order.can_ship?
      )
    end
  end
end