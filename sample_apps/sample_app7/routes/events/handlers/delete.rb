# frozen_string_literal: true

class EventsDeleteHandler < MK::Handler
  handler do |r|
    success do |r|
      {
        message: "Event deleted successfully",
        event: model[:event]
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