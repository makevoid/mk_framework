# frozen_string_literal: true

class CardsIndexController < MK::Controller
  route do |r|
    Card.all
  end
end