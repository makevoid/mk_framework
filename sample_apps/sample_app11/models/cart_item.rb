# frozen_string_literal: true

class CartItem < Sequel::Model
  plugin :validation_helpers
  plugin :timestamps
  
  many_to_one :user
  many_to_one :product
  
  def validate
    super
    validates_presence [:user_id, :product_id, :quantity]
    validates_numeric :quantity
    validates_operator :>, 0, :quantity
    validates_unique [:user_id, :product_id]
  end
  
  def total_price
    quantity * product.price
  end
  
  def can_fulfill?
    product.stock_quantity >= quantity
  end
end