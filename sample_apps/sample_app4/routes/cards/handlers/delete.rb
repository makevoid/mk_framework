# frozen_string_literal: true

class CardsDeleteHandler < MK::Handler
  def call
    response.status = 200
    {
      message: "Card deleted successfully",
      card: controller_result.values
    }.to_json
  end
end