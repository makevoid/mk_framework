# frozen_string_literal: true

require_relative 'base'

module SampleApp7
  class CardsMoveController < CardsController
    route do |r|
      write_card(r, move: true)
    end
  end
end
