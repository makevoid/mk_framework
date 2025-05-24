# frozen_string_literal: true

class EventsDeleteController < MK::Controller
  route do |r|
    event = Event[r.params['id']]
    r.halt(404, { error: "Event not found" }) unless event
    
    # Store the values before deletion for use in the handler
    event.instance_variable_set(:@deleted_values, event.values.dup)
    
    # Return the event model for the framework to handle
    event
  end
end