# frozen_string_literal: true

class BookingsShowHandler < MK::Handler
  handler do |r|
    if model.nil?
      r.response.status = 404
      { error: "Booking not found" }
    else
      model.to_hash
    end
  end
end