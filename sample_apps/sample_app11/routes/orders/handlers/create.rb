# frozen_string_literal: true

class OrdersCreateHandler < MK::Handler
  handler do |r|
    success do
      response.status = 201
      {
        order: model.to_hash.merge(
          items_count: model.items_count,
          formatted_total: model.formatted_total,
          can_cancel: model.can_cancel?,
          can_ship: model.can_ship?
        ),
        message: "Order created successfully"
      }
    end
  end
end