# frozen_string_literal: true

class EventsShowHandler < MK::Handler
  handler do |r|
    model.to_hash
  end
end