# frozen_string_literal: true

class BookingsDeleteHandler < MK::Handler
  handler do |r|
    success do |r|
      {
        message: "Booking deleted successfully",
        booking: model.to_hash
      }
    end

    error do |r|
      r.response.status = 500
      {
        error: "Failed to delete booking"
      }
    end
  end
end