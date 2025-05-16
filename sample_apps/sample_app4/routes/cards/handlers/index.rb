# frozen_string_literal: true

class CardsIndexHandler < MK::Handler
  def call
    { 
      cards: controller_result.map(&:values)
    }.to_json
  end
end