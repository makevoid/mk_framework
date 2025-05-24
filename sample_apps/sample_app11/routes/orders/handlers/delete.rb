# frozen_string_literal: true

class OrdersDeleteHandler < MK::Handler
  handler do |r|
    success do
      {
        order_id: model[:id],
        message: "Order deleted successfully"
      }
    end
  end
end