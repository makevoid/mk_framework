# frozen_string_literal: true

class TasksShowHandler < MK::Handler
  handler do |r|
    model.to_hash(include_associations: true)
  end
end