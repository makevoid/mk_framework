# frozen_string_literal: true

class BookingsUpdateController < MK::Controller
  route do |r|
    booking = Booking[r.params.fetch('id')]

    r.halt(404, { message: "Booking not found" }) if booking.nil?

    params = r.params

    booking.set({
      room_type: params['room_type'],
      guest_name: params['guest_name'],
      num_guests: params['num_guests']&.to_i,
      start_date: params['start_date'],
      end_date: params['end_date']
    }.compact)

    booking
  end
end