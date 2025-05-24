# frozen_string_literal: true

class CartsDeleteHandler < MK::Handler
  handler do |r|
    success do |r|
      if r.params.key?('item_id')
        {
          message: "Item removed from cart",
          cart: model.to_hash
        }
      else
        {
          message: "Cart cleared",
          cart: model.to_hash
        }
      end
    end

    error do |r|
      { error: r.params['error'] || "Failed to modify cart" }
    end
  end
end