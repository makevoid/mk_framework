# frozen_string_literal: true

class BookingsShowController < MK::Controller
  route do |r|
    Booking[r.params.fetch('id')]
  end
end