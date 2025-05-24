# frozen_string_literal: true

class BookingsDeleteController < MK::Controller
  route do |r|
    booking = Booking[r.params.fetch('id')]

    r.halt(404, { message: "Booking not found" }) if booking.nil?

    booking
  end
end