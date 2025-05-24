# frozen_string_literal: true

class ProductsShowHandler < MK::Handler
  handler do |r|
    model.to_hash
  end
end