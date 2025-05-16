# frozen_string_literal: true

class CardsShowHandler < MK::Handler
  route do |r|
    result = controller_result

    {
      card: result[:card].values,
      comments: result[:comments].map(&:values)
    }.to_json
  end
end
