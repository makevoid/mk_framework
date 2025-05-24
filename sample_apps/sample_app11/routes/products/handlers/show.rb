# frozen_string_literal: true

class ProductsShowHandler < MK::Handler
  handler do |r|
    {
      product: model
    }
  end
end