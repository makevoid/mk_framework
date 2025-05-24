# frozen_string_literal: true

class CartItem < Sequel::Model
  plugin :validation_helpers
  
  many_to_one :cart
  many_to_one :product

  def validate
    super
    validates_presence [:cart_id, :product_id, :quantity, :price]
    validates_integer :quantity
    validates_operator(:>, 0, :quantity)
    validates_numeric :price
    validates_operator(:>=, 0, :price)
  end

  def subtotal
    quantity * price
  end

  def to_hash
    {
      id: id,
      product: product.to_hash,
      quantity: quantity,
      price: price.to_f,
      subtotal: subtotal.to_f
    }
  end
end