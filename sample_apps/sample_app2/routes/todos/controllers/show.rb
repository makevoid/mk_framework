# frozen_string_literal: true

class TodosShowController < MK::Controller
  route do |r|
    Todo[r.params.fetch('id')]
  end
end
