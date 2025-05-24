# frozen_string_literal: true

class EventsCreateHandler < MK::Handler
  handler do |r|
    success do |r|
      r.response.status = 201
      {
        message: "Event created",
        event: model.to_hash,
      }
    end

    error do |r|
      r.response.status = 422
      {
        error: "Validation failed",
        details: model.errors
      }
    end
  end
end