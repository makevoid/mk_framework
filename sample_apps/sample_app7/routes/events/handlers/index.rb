# frozen_string_literal: true

class EventsIndexHandler < MK::Handler
  handler do |r|
    success do |r|
      r.response.status = 200
      model.map(&:to_hash)
    end
  end
end