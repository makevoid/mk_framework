# frozen_string_literal: true

require 'spec_helper'

describe "Events" do
  describe "GET /events" do
    before do
      Event.dataset.delete

      @event1 = Event.create(
        title: "Team Meeting",
        description: "Weekly team sync",
        start_time: "2024-05-20T10:00:00Z",
        end_time: "2024-05-20T11:00:00Z",
        location: "Conference Room A",
        all_day: false
      )

      @event2 = Event.create(
        title: "Company Holiday",
        description: "Annual company day off",
        start_time: "2024-05-27T00:00:00Z",
        end_time: "2024-05-27T23:59:59Z",
        all_day: true
      )
    end

    it "returns all events" do
      get '/events'

      expect(last_response.status).to eq 200

      expect(resp.length).to eq 2

      expect(resp[0][:id]).to eq @event1.id
      expect(resp[0][:title]).to eq "Team Meeting"
      expect(resp[0][:description]).to eq "Weekly team sync"
      expect(resp[0][:start_time]).to be_a(String)
      expect(resp[0][:end_time]).to be_a(String)
      expect(resp[0][:location]).to eq "Conference Room A"
      expect(resp[0][:all_day]).to eq false

      expect(resp[1][:id]).to eq @event2.id
      expect(resp[1][:title]).to eq "Company Holiday"
      expect(resp[1][:description]).to eq "Annual company day off"
      expect(resp[1][:start_time]).to be_a(String)
      expect(resp[1][:end_time]).to be_a(String)
      expect(resp[1][:all_day]).to eq true
    end
  end

  describe "GET /events/:id" do
    before do
      Event.dataset.delete

      @event = Event.create(
        title: "Product Demo",
        description: "Showcase new features",
        start_time: "2024-05-22T14:00:00Z",
        end_time: "2024-05-22T15:30:00Z",
        location: "Main Hall",
        all_day: false
      )
    end

    context "when event exists" do
      it "returns the event" do
        get "/events/#{@event.id}"

        expect(last_response.status).to eq 200

        expect(resp[:id]).to eq @event.id
        expect(resp[:title]).to eq "Product Demo"
        expect(resp[:description]).to eq "Showcase new features"
        expect(resp[:start_time]).to be_a(String)
        expect(resp[:end_time]).to be_a(String)
        expect(resp[:location]).to eq "Main Hall"
        expect(resp[:all_day]).to eq false
      end
    end

    context "when event does not exist" do
      it "returns a 404 error" do
        get "/events/999999"

        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "Event not found"
      end
    end
  end

  describe "POST /events" do
    context "with valid parameters" do
      it "creates a new event" do
        post '/events', {
          title: "Client Meeting",
          description: "Discuss project timeline",
          start_time: "2024-05-25T09:00:00Z",
          end_time: "2024-05-25T10:00:00Z",
          location: "Conference Room B"
        }

        expect(last_response.status).to eq 201

        expect(resp[:message]).to eq "Event created"
        expect(resp[:event][:title]).to eq "Client Meeting"
        expect(resp[:event][:description]).to eq "Discuss project timeline"
        expect(resp[:event][:start_time]).to be_a(String)
        expect(resp[:event][:end_time]).to be_a(String)
        expect(resp[:event][:location]).to eq "Conference Room B"
        expect(resp[:event][:all_day]).to eq false
      end

      it "creates an all-day event" do
        post '/events', {
          title: "Conference Day",
          description: "Annual industry conference",
          start_time: "2024-06-15T00:00:00Z",
          end_time: "2024-06-15T23:59:59Z",
          all_day: true
        }

        expect(last_response.status).to eq 201

        expect(resp[:message]).to eq "Event created"
        expect(resp[:event][:title]).to eq "Conference Day"
        expect(resp[:event][:all_day]).to eq true
      end
    end

    context "with invalid parameters" do
      it "returns validation errors when title is missing" do
        post '/events', {
          description: "Missing title event",
          start_time: "2024-05-29T10:00:00Z"
        }

        expect(last_response.status).to eq 422

        expect(resp[:error]).to eq "Validation failed"
        expect(resp[:details]).to have_key :title
      end

      it "returns validation errors when start_time is missing" do
        post '/events', {
          title: "Invalid Event",
          description: "No start time provided"
        }

        expect(last_response.status).to eq 422

        expect(resp[:error]).to eq "Validation failed"
        expect(resp[:details]).to have_key :start_time
      end

      it "returns validation errors when title is too long" do
        post '/events', {
          title: "X" * 101,
          description: "This event has a title that is too long",
          start_time: "2024-05-30T15:00:00Z"
        }

        expect(last_response.status).to eq 422

        expect(resp[:error]).to eq "Validation failed"
        expect(resp[:details]).to have_key :title
      end
    end
  end

  describe "PUT /events/:id" do
    before do
      Event.dataset.delete

      @event = Event.create(
        title: "Original Event",
        description: "Original Description",
        start_time: "2024-06-01T13:00:00Z",
        end_time: "2024-06-01T14:00:00Z",
        location: "Original Location",
        all_day: false
      )
    end

    context "when event exists" do
      it "updates the event title" do
        post "/events/#{@event.id}", {
          title: "Updated Title"
        }

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Event updated"
        expect(resp[:event][:id]).to eq @event.id
        expect(resp[:event][:title]).to eq "Updated Title"
        expect(resp[:event][:description]).to eq "Original Description"
        expect(resp[:event][:start_time]).to be_a(String)
      end

      it "updates the event time" do
        post "/events/#{@event.id}", {
          start_time: "2024-06-01T14:00:00Z",
          end_time: "2024-06-01T15:30:00Z"
        }

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Event updated"
        expect(resp[:event][:id]).to eq @event.id
        expect(resp[:event][:title]).to eq "Original Event"
        expect(resp[:event][:start_time]).to be_a(String)
        expect(resp[:event][:end_time]).to be_a(String)
      end

      it "updates the event to all-day" do
        post "/events/#{@event.id}", {
          all_day: true
        }

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Event updated"
        expect(resp[:event][:id]).to eq @event.id
        expect(resp[:event][:all_day]).to eq true
      end

      it "updates multiple fields at once" do
        post "/events/#{@event.id}", {
          title: "Completely Updated",
          description: "New Description",
          location: "New Location",
          start_time: "2024-06-02T10:00:00Z",
          end_time: "2024-06-02T11:00:00Z"
        }

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Event updated"
        expect(resp[:event][:id]).to eq @event.id
        expect(resp[:event][:title]).to eq "Completely Updated"
        expect(resp[:event][:description]).to eq "New Description"
        expect(resp[:event][:location]).to eq "New Location"
        expect(resp[:event][:start_time]).to be_a(String)
        expect(resp[:event][:end_time]).to be_a(String)
      end

      it "returns validation errors when title is too long" do
        post "/events/#{@event.id}", {
          title: "X" * 101
        }

        expect(last_response.status).to eq 400

        expect(resp[:error]).to eq "Validation failed!"
        expect(resp[:details]).to have_key :title
      end
    end

    context "when event does not exist" do
      it "returns a 404 error" do
        post "/events/999999", {
          title: "Updated Title"
        }

        expect(last_response.status).to eq 404
        expect(resp[:message]).to eq "event not found"
      end
    end
  end

  describe "DELETE /events/:id" do
    before do
      Event.dataset.delete

      @event = Event.create(
        title: "Event to Delete",
        description: "This event will be deleted",
        start_time: "2024-06-05T09:00:00Z",
        end_time: "2024-06-05T10:30:00Z",
        location: "Delete Room",
        all_day: false
      )
    end

    context "when event exists" do
      it "deletes the event" do
        post "/events/#{@event.id}/delete"

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Event deleted successfully"
        expect(resp[:event][:id]).to eq @event.id
        expect(resp[:event][:title]).to eq "Event to Delete"
        expect(resp[:event][:description]).to eq "This event will be deleted"

        # Verify that the event was actually deleted from the database
        expect(Event[@event.id]).to be_nil
      end
    end

    context "when event does not exist" do
      it "returns a 404 error" do
        delete "/events/999999"

        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "Event not found"
      end
    end
  end
end