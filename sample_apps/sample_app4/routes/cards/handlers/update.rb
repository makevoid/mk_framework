# frozen_string_literal: true

class CardsUpdateHandler < MK::Handler
  def call
    response.status = 200
    {
      message: "Card updated",
      card: controller_result.values
    }.to_json
  end
end