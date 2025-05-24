# frozen_string_literal: true

class UsersDeleteController < MK::Controller
  route do |r|
    user_id = r.params.fetch('id')
    user = User[user_id]
    
    r.halt(404, { error: "User not found" }.to_json) unless user
    
    # Check if user has orders
    if user.orders.count > 0
      r.halt(400, { 
        error: "Cannot delete user that has orders" 
      }.to_json)
    end
    
    # Clear cart items first
    user.cart_items.each(&:delete)
    
    user.delete
    { id: user_id.to_i }
  end
end