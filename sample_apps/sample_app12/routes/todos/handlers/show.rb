# frozen_string_literal: true

class TodosShowHandler < MK::Handler
  handler do |r|
    model.to_hash
  end
end
