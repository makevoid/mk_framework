# frozen_string_literal: true

require 'spec_helper'
require 'date'

describe "Bookings API" do
  before(:each) do
    Booking.dataset.delete
  end

  let(:valid_booking_params_room2) do
    {
      room_type: "room_for_2",
      guest_name: "John Doe",
      num_guests: 2,
      start_date: (Date.today + 1).strftime('%Y-%m-%d'),
      end_date: (Date.today + 5).strftime('%Y-%m-%d')
    }
  end

  let(:valid_booking_params_room3) do
    {
      room_type: "room_for_3",
      guest_name: "Jane Smith Family",
      num_guests: 3,
      start_date: (Date.today + 10).strftime('%Y-%m-%d'),
      end_date: (Date.today + 15).strftime('%Y-%m-%d')
    }
  end

  describe "POST /bookings" do
    context "with valid parameters" do
      it "creates a new booking for room_for_2" do
        post '/bookings', valid_booking_params_room2
        expect(last_response.status).to eq 201
        expect(resp[:message]).to eq "Booking created"
        expect(resp[:booking][:room_type]).to eq "room_for_2"
        expect(resp[:booking][:guest_name]).to eq "John Doe"
        expect(resp[:booking][:num_guests]).to eq 2
        expect(resp[:booking][:start_date]).to eq valid_booking_params_room2[:start_date]
        expect(resp[:booking][:end_date]).to eq valid_booking_params_room2[:end_date]
      end

      it "creates a new booking for room_for_3" do
        post '/bookings', valid_booking_params_room3
        expect(last_response.status).to eq 201
        expect(resp[:booking][:room_type]).to eq "room_for_3"
        expect(resp[:booking][:num_guests]).to eq 3
      end
    end

    context "with invalid parameters" do
      it "returns validation error for missing guest_name" do
        post '/bookings', valid_booking_params_room2.merge(guest_name: nil)
        expect(last_response.status).to eq 422
        expect(resp[:error]).to eq "Validation failed"
        expect(resp[:details][:guest_name]).to include("is not present")
      end

      it "returns validation error for invalid room_type" do
        post '/bookings', valid_booking_params_room2.merge(room_type: "penthouse")
        expect(last_response.status).to eq 422
        expect(resp[:details][:room_type]).to include("is not a valid room type. Available: room_for_2, room_for_3")
      end

      it "returns validation error for num_guests exceeding capacity for room_for_2" do
        post '/bookings', valid_booking_params_room2.merge(num_guests: 3)
        expect(last_response.status).to eq 422
        expect(resp[:details][:num_guests]).to include("exceeds capacity for room_for_2 (max: 2)")
      end

      it "returns validation error for num_guests exceeding capacity for room_for_3" do
        post '/bookings', valid_booking_params_room3.merge(num_guests: 4)
        expect(last_response.status).to eq 422
        expect(resp[:details][:num_guests]).to include("exceeds capacity for room_for_3 (max: 3)")
      end
      
      it "returns validation error for num_guests being zero or negative" do
        post '/bookings', valid_booking_params_room2.merge(num_guests: 0)
        expect(last_response.status).to eq 422
        expect(resp[:details][:num_guests]).to include("must be a positive integer")
      end

      it "returns validation error for start_date after end_date" do
        post '/bookings', valid_booking_params_room2.merge(start_date: (Date.today + 5).strftime('%Y-%m-%d'), end_date: (Date.today + 1).strftime('%Y-%m-%d'))
        expect(last_response.status).to eq 422
        expect(resp[:details][:end_date]).to include("must be after start_date")
      end

      it "returns validation error for invalid date format" do
        post '/bookings', valid_booking_params_room2.merge(start_date: "invalid-date")
        expect(last_response.status).to eq 422
        expect(resp[:details][:start_date]).to include("is not a valid date format")
      end

      it "returns validation error for overlapping booking" do
        Booking.create(valid_booking_params_room2)
        post '/bookings', valid_booking_params_room2.merge(start_date: (Date.today + 2).strftime('%Y-%m-%d'), end_date: (Date.today + 6).strftime('%Y-%m-%d'))
        
        expect(last_response.status).to eq 422
        expect(resp[:details][:base]).to include(/The room 'Double Room \(2 people\)' is already booked for the selected dates/)
      end

      it "allows booking the other room type if one is full for those dates" do
        Booking.create(valid_booking_params_room2)
        
        overlapping_params_for_room3 = {
          room_type: "room_for_3",
          guest_name: "Another Guest",
          num_guests: 3,
          start_date: valid_booking_params_room2[:start_date],
          end_date: valid_booking_params_room2[:end_date]
        }
        post '/bookings', overlapping_params_for_room3
        expect(last_response.status).to eq 201
        expect(resp[:booking][:room_type]).to eq "room_for_3"
      end
    end
  end

  describe "GET /bookings" do
    it "returns all bookings" do
      booking1 = Booking.create(valid_booking_params_room2)
      booking2_params = valid_booking_params_room3.merge(
        start_date: (Date.today + 20).strftime('%Y-%m-%d'),
        end_date: (Date.today + 25).strftime('%Y-%m-%d')
      )
      booking2 = Booking.create(booking2_params)

      get '/bookings'
      expect(last_response.status).to eq 200
      expect(resp.length).to eq 2
      expect(resp.map { |b| b[:id] }).to contain_exactly(booking1.id, booking2.id)
    end
  end

  describe "GET /bookings/:id" do
    context "when booking exists" do
      it "returns the booking" do
        booking = Booking.create(valid_booking_params_room2)
        get "/bookings/#{booking.id}"
        expect(last_response.status).to eq 200
        expect(resp[:id]).to eq booking.id
        expect(resp[:guest_name]).to eq "John Doe"
      end
    end

    context "when booking does not exist" do
      it "returns a 404 error" do
        get "/bookings/99999"
        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "Booking not found"
      end
    end
  end

  describe "POST /bookings/:id (Update)" do
    let!(:booking) { Booking.create(valid_booking_params_room2) }

    context "with valid parameters" do
      it "updates the booking's guest_name" do
        post "/bookings/#{booking.id}", { guest_name: "Johnathan Doe Updated" }
        expect(last_response.status).to eq 200
        expect(resp[:message]).to eq "Booking updated"
        expect(resp[:booking][:guest_name]).to eq "Johnathan Doe Updated"
        expect(booking.reload.guest_name).to eq "Johnathan Doe Updated"
      end

      it "updates the booking's dates" do
        new_start_date = (Date.today + 6).strftime('%Y-%m-%d')
        new_end_date = (Date.today + 10).strftime('%Y-%m-%d')
        post "/bookings/#{booking.id}", { start_date: new_start_date, end_date: new_end_date }
        expect(last_response.status).to eq 200
        expect(resp[:booking][:start_date]).to eq new_start_date
        expect(resp[:booking][:end_date]).to eq new_end_date
      end
    end

    context "with invalid parameters" do
      it "returns validation error for num_guests exceeding capacity" do
        post "/bookings/#{booking.id}", { num_guests: 5 }
        expect(last_response.status).to eq 422
        expect(resp[:details][:num_guests]).to include("exceeds capacity for room_for_2 (max: 2)")
      end

      it "returns validation error for overlapping dates with another booking" do
        # Use room_for_3 to avoid conflicts with existing room_for_2 bookings
        other_booking = Booking.create(
          room_type: "room_for_3",
          guest_name: "Other Guest", 
          num_guests: 2,
          start_date: (Date.today + 50).strftime('%Y-%m-%d'),
          end_date: (Date.today + 55).strftime('%Y-%m-%d')
        )
        
        # Try to update original booking to use room_for_3 and overlap with the other booking
        post "/bookings/#{booking.id}", { room_type: "room_for_3", start_date: (Date.today + 49).strftime('%Y-%m-%d'), end_date: (Date.today + 52).strftime('%Y-%m-%d') }
        expect(last_response.status).to eq 422
        expect(resp[:details][:base]).to include(/The room 'Triple Room \(3 people\)' is already booked for the selected dates/)
      end
      
      it "allows updating dates if there is no overlap" do
        post "/bookings/#{booking.id}", { start_date: (Date.today + 7).strftime('%Y-%m-%d'), end_date: (Date.today + 9).strftime('%Y-%m-%d') }
        expect(last_response.status).to eq 200
        expect(resp[:booking][:start_date]).to eq (Date.today + 7).strftime('%Y-%m-%d')
      end
    end

    context "when booking does not exist" do
      it "returns a 404 error" do
        post "/bookings/99999", { guest_name: "Ghost Guest" }
        expect(last_response.status).to eq 404
        expect(resp[:message]).to eq "Booking not found"
      end
    end
  end

  describe "POST /bookings/:id/delete" do
    let!(:booking) { Booking.create(valid_booking_params_room2) }

    context "when booking exists" do
      it "deletes the booking" do
        post "/bookings/#{booking.id}/delete"
        expect(last_response.status).to eq 200
        expect(resp[:message]).to eq "Booking deleted successfully"
        expect(resp[:booking][:id]).to eq booking.id
        expect(Booking[booking.id]).to be_nil
      end
    end

    context "when booking does not exist" do
      it "returns a 404 error" do
        post "/bookings/99999/delete"
        expect(last_response.status).to eq 404
        expect(resp[:message]).to eq "Booking not found"
      end
    end
  end
end