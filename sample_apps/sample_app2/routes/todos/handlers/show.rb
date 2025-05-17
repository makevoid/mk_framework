# frozen_string_literal: true

class TodosShowHandler < MK::Handler
  route do |r|
    model.to_hash
  end
end
