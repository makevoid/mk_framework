# frozen_string_literal: true

class CardsShowHandler < MK::Handler
  handler do |r|
    {
      card: model.fetch(:card).to_hash,
      comments: model.fetch(:comments).map(&:to_hash)
    }
  end
end
