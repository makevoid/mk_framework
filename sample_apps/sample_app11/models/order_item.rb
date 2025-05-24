# frozen_string_literal: true

class OrderItem < Sequel::Model
  plugin :validation_helpers
  plugin :timestamps
  
  many_to_one :order
  many_to_one :product
  
  def validate
    super
    validates_presence [:order_id, :product_id, :quantity, :unit_price, :total_price]
    validates_numeric :quantity, :unit_price, :total_price
    validates_operator :>, 0, :quantity
    validates_operator :>=, 0, :unit_price, :total_price
  end
  
  def before_create
    self.total_price = quantity * unit_price
    super
  end
  
  def before_update
    self.total_price = quantity * unit_price
    super
  end
end