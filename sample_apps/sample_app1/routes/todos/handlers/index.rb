# frozen_string_literal: true

class TodosIndexHandler < MK::Handler
  route do |r|
    if model.empty?
      []
    else
      model.map(&:to_hash)
    end
  end
end
