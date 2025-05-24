# frozen_string_literal: true

class EventsShowController < MK::Controller
  route do |r|
    event = Event[r.params['id']]
    r.halt(404, { error: "Event not found" }) unless event
    event
  end
end