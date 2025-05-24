# frozen_string_literal: true

class CheckoutsCreateHandler < MK::Handler
  handler do |r|
    success do |r|
      r.response.status = 201
      {
        message: "Order placed successfully",
        order: model.to_hash
      }
    end

    error do |r|
      r.response.status = 422
      {
        error: "Checkout failed",
        details: model.errors
      }
    end
  end
end