# frozen_string_literal: true

class UsersIndexController < MK::Controller
  route do |r|
    users = User.order(:last_name, :first_name)
    
    # Search by name or email if specified
    if r.params['search']
      search_term = "%#{r.params['search']}%"
      users = users.where(
        Sequel.ilike(:first_name, search_term) |
        Sequel.ilike(:last_name, search_term) |
        Sequel.ilike(:email, search_term)
      )
    end
    
    users.all.map do |user|
      user.to_hash.merge(
        full_name: user.full_name,
        cart_items_count: user.cart_items_count,
        cart_total: user.cart_total,
        orders_count: user.orders.count
      )
    end
  end
end