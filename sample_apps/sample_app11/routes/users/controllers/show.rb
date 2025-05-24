# frozen_string_literal: true

class UsersShowController < MK::Controller
  route do |r|
    user_id = r.params.fetch('id')
    user = User[user_id]
    
    r.halt(404, { error: "User not found" }.to_json) unless user
    
    user.to_hash.merge(
      full_name: user.full_name,
      cart_items_count: user.cart_items_count,
      cart_total: user.cart_total,
      orders_count: user.orders.count,
      recent_orders: user.orders.order(:created_at).reverse.limit(5).map(&:to_hash)
    )
  end
end