# frozen_string_literal: true

class Product < Sequel::Model
  plugin :validation_helpers
  plugin :timestamps

  many_to_one :category
  one_to_many :cart_items
  one_to_many :order_items

  def validate
    super
    validates_presence [:name, :price, :category_id]
    validates_unique :sku if sku
    validates_max_length 200, :name
    validates_max_length 50, :sku if sku
    validates_numeric :price
    validates_numeric :stock_quantity
    validates_operator :>=, 0, :price
    validates_operator :>=, 0, :stock_quantity
  end

  def in_stock?
    stock_quantity > 0
  end

  def available_quantity
    [stock_quantity, 0].max
  end

  def formatted_price
    "$%.2f" % price
  end

  def reduce_stock(quantity)
    update(stock_quantity: [stock_quantity - quantity, 0].max)
  end

  def increase_stock(quantity)
    update(stock_quantity: stock_quantity + quantity)
  end
end
