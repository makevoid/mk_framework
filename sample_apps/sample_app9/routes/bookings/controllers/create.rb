# frozen_string_literal: true

class BookingsCreateController < MK::Controller
  route do |r|
    Booking.new(
      room_type: r.params['room_type'],
      guest_name: r.params['guest_name'],
      num_guests: r.params['num_guests']&.to_i,
      start_date: r.params['start_date'],
      end_date: r.params['end_date']
    )
  end
end