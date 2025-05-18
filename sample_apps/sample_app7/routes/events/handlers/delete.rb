# frozen_string_literal: true

class EventsDeleteHandler < MK::Handler
  handler do |r|
    success do |r|
      r.response.status = 200
      {
        message: "Event deleted successfully",
        event: model[:event]
      }
    end
  end
end