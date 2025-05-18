# frozen_string_literal: true

class EventsShowHandler < MK::Handler
  handler do |r|
    success do |r|
      r.response.status = 200
      model.to_hash
    end
  end
end