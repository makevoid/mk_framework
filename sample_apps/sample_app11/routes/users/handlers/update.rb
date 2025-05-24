# frozen_string_literal: true

class UsersUpdateHandler < MK::Handler
  handler do |r|
    success do
      {
        user: model.to_hash.merge(
          full_name: model.full_name,
          cart_items_count: model.cart_items_count,
          cart_total: model.cart_total
        ),
        message: "User updated successfully"
      }
    end
  end
end