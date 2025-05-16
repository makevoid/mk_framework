# frozen_string_literal: true

class CardsCreateController < MK::Controller
  route do |r|
    Card.new(
      title: r.params['title'],
      description: r.params['description'],
      status: r.params['status'] || 'todo'
    )
  end
end