# frozen_string_literal: true

class CartsIndexController < MK::Controller
  route do |r|
    user_id = r.params.fetch('user_id')
    user = User[user_id]
    
    r.halt(404, { error: "User not found" }.to_json) unless user
    
    cart_items = user.cart_items
                     .join(:products, id: :product_id)
                     .select_all(:cart_items)
                     .select_append(:products__name___product_name)
                     .select_append(:products__price___product_price)
                     .select_append(:products__stock_quantity___product_stock)
                     .order(:cart_items__created_at)
    
    {
      user_id: user.id,
      cart_items: cart_items.all.map do |item|
        item.to_hash.merge(
          product_name: item[:product_name],
          product_price: item[:product_price],
          product_stock: item[:product_stock],
          total_price: item.total_price,
          can_fulfill: item.can_fulfill?
        )
      end,
      cart_total: user.cart_total,
      items_count: user.cart_items_count
    }
  end
end