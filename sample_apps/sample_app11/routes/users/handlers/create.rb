# frozen_string_literal: true

class UsersCreateHandler < MK::Handler
  handler do |r|
    success do
      response.status = 201
      {
        user: model.to_hash.merge(
          full_name: model.full_name,
          cart_items_count: model.cart_items_count,
          cart_total: model.cart_total
        ),
        message: "User created successfully"
      }
    end
  end
end