# frozen_string_literal: true

class BookingsIndexHandler < MK::Handler
  handler do |r|
    model.map(&:to_hash)
  end
end