# frozen_string_literal: true

class CartsShowController < MK::Controller
  route do |r|
    session_id = r.params.fetch('id')
    
    cart = Cart.find(session_id: session_id)
    
    # Create cart if it doesn't exist
    cart ||= Cart.create(session_id: session_id)
    
    cart
  end
end