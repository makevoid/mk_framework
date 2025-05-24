# frozen_string_literal: true

class BookingsUpdateHandler < MK::Handler
  handler do |r|
    success do |r|
      {
        message: "Booking updated",
        booking: model.to_hash,
      }
    end

    error do |r|
      r.response.status = 422
      {
        error: "Validation failed",
        details: model.errors
      }
    end
  end
end