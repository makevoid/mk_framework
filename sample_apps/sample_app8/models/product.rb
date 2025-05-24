# frozen_string_literal: true

class Product < Sequel::Model
  plugin :validation_helpers
  
  one_to_many :cart_items

  def validate
    super
    validates_presence [:name, :price, :stock]
    validates_max_length 200, :name
    validates_max_length 1000, :description if description
    validates_numeric :price
    validates_operator(:>=, 0, :price)
    validates_integer :stock
    validates_operator(:>=, 0, :stock)
    validates_unique :sku if sku
  end

  def available?
    active && stock > 0
  end

  def reduce_stock!(quantity)
    raise "Insufficient stock" if stock < quantity
    update(stock: stock - quantity)
  end

  def increase_stock!(quantity)
    update(stock: stock + quantity)
  end

  def to_hash
    {
      id: id,
      name: name,
      description: description,
      price: price.to_f,
      stock: stock,
      sku: sku,
      image_url: image_url,
      active: active,
      created_at: created_at,
      updated_at: updated_at
    }
  end
end
