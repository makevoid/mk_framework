# frozen_string_literal: true

class ProductsIndexHandler < MK::Handler
  handler do |r|
    model.map(&:to_hash)
  end
end