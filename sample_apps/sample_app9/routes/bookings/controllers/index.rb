# frozen_string_literal: true

class BookingsIndexController < MK::Controller
  route do |r|
    Booking.order(Sequel.asc(:start_date), Sequel.asc(:room_type)).all
  end
end