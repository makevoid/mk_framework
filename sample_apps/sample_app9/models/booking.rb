# frozen_string_literal: true

require 'date'

class Booking < Sequel::Model
  plugin :validation_helpers
  plugin :timestamps, update_on_create: true

  AVAILABLE_ROOMS = {
    "room_for_2" => { capacity: 2, name: "Double Room (2 people)" },
    "room_for_3" => { capacity: 3, name: "Triple Room (3 people)" }
  }.freeze

  def validate
    super
    validates_presence [:room_type, :guest_name, :start_date, :end_date, :num_guests]

    if room_type
      unless AVAILABLE_ROOMS.key?(room_type)
        errors.add(:room_type, "is not a valid room type. Available: #{AVAILABLE_ROOMS.keys.join(', ')}")
      end
    end

    if num_guests
      if num_guests.is_a?(Integer) && num_guests > 0
        if room_type && AVAILABLE_ROOMS.key?(room_type)
          max_capacity = AVAILABLE_ROOMS[room_type][:capacity]
          if num_guests > max_capacity
            errors.add(:num_guests, "exceeds capacity for #{room_type} (max: #{max_capacity})")
          end
        end
      else
        errors.add(:num_guests, "must be a positive integer")
      end
    end

    valid_start_date = start_date.is_a?(Date)
    valid_end_date = end_date.is_a?(Date)

    if !valid_start_date && values.key?(:start_date)
      errors.add(:start_date, "is not a valid date format") unless errors[:start_date]&.any?
    end
    if !valid_end_date && values.key?(:end_date)
      errors.add(:end_date, "is not a valid date format") unless errors[:end_date]&.any?
    end

    if valid_start_date && valid_end_date
      if start_date >= end_date
        errors.add(:end_date, "must be after start_date")
      end

      if room_type && AVAILABLE_ROOMS.key?(room_type)
        query = Booking.where(room_type: room_type)
        query = query.exclude(id: self.id) if self.id
        
        overlapping = query.where{ (Sequel.qualify(:bookings, :start_date) < self.end_date) & (Sequel.qualify(:bookings, :end_date) > self.start_date) }.first

        if overlapping
          errors.add(:base, "The room '#{AVAILABLE_ROOMS[room_type][:name]}' is already booked for the selected dates: #{overlapping.start_date.strftime('%Y-%m-%d')} to #{overlapping.end_date.strftime('%Y-%m-%d')}.")
        end
      end
    end
  end

  def to_hash
    super.merge(
      start_date: start_date&.strftime('%Y-%m-%d'),
      end_date: end_date&.strftime('%Y-%m-%d')
    )
  end
end