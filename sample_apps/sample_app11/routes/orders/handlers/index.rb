# frozen_string_literal: true

class OrdersIndexHandler < MK::Handler
  handler do |r|
    {
      orders: model,
      total_count: model.length,
      filters_applied: {
        user_id: r.params['user_id'],
        status: r.params['status']
      }
    }
  end
end