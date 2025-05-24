# frozen_string_literal: true

require 'sequel'
require 'json'
require 'roda'
require_relative '../../lib/mk_framework'

# Set up database connection
DB_FILE = ENV['RACK_ENV'] == 'test' ? ':memory:' : 'hotel_bookings.db'
DB = Sequel.connect("sqlite://#{DB_FILE}")

# Create bookings table if it doesn't exist
DB.create_table? :bookings do
  primary_key :id
  String :room_type, null: false
  String :guest_name, null: false
  Integer :num_guests, null: false
  Date :start_date, null: false
  Date :end_date, null: false
  DateTime :created_at
  DateTime :updated_at

  index [:room_type, :start_date]
  index [:room_type, :end_date]
end

# Require models
require_relative 'models/booking'

# Create application instance
class HotelApp < MK::Application
end
