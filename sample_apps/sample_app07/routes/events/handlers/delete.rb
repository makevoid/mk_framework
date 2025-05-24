# frozen_string_literal: true

class EventsDeleteHandler < MK::Handler
  handler do |r|
    success do |r|
      # Get the stored values before deletion
      event_values = model.instance_variable_get(:@deleted_values) || model.values
      
      {
        message: "Event deleted successfully",
        event: event_values
      }
    end

    error do |r|
      r.response.status = 500
      {
        error: "Failed to delete event"
      }
    end
  end
end