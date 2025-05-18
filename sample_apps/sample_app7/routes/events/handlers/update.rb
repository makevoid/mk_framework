# frozen_string_literal: true

class EventsUpdateHandler < MK::Handler
  handler do |r|
    success do |r|
      r.response.status = 200
      {
        message: "Event updated",
        event: model.to_hash
      }
    end

    error do |r|
      r.response.status = 400
      {
        error: "Validation failed!",
        details: model.errors
      }
    end
  end
end