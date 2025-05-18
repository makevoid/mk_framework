# frozen_string_literal: true

class EventsDeleteController < MK::Controller
  route do |r|
    event = Event[r.params['id']]
    r.halt(404, { error: "Event not found" }) unless event
    
    deleted_event = event.values.dup
    event.delete
    { event: deleted_event }
  end
end