# frozen_string_literal: true

class OrdersShowHandler < MK::Handler
  handler do |r|
    {
      order: model
    }
  end
end