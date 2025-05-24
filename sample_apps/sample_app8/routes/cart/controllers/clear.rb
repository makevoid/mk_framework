# frozen_string_literal: true

class CartClearController < MK::Controller
  route do |r|
    session_id = r.params.fetch('id')
    
    cart = Cart.find(session_id: session_id)
    r.halt(404, { error: "Cart not found" }) if cart.nil?
    
    cart.clear!
    
    cart
  end
end