# frozen_string_literal: true

class CardsShowHandler < MK::Handler
  def call
    result = controller_result
    
    {
      card: result[:card].values,
      comments: result[:comments].map(&:values)
    }.to_json
  end
end