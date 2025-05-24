# frozen_string_literal: true

class Cart < Sequel::Model
  plugin :validation_helpers
  
  one_to_many :cart_items
  one_to_many :orders

  def validate
    super
    validates_presence [:session_id]
    validates_unique :session_id
  end

  def total
    cart_items.sum { |item| item.quantity * item.price }
  end

  def item_count
    cart_items.sum { |item| item.quantity }
  end

  def empty?
    cart_items.empty?
  end

  def clear!
    cart_items.each(&:destroy)
  end

  def add_item(product, quantity = 1)
    existing_item = cart_items.find { |item| item.product_id == product.id }
    
    if existing_item
      existing_item.update(quantity: existing_item.quantity + quantity)
    else
      add_cart_item(
        product_id: product.id,
        quantity: quantity,
        price: product.price
      )
    end
  end

  def to_hash
    {
      id: id,
      session_id: session_id,
      total: total.to_f,
      item_count: item_count,
      items: cart_items.map(&:to_hash),
      created_at: created_at,
      updated_at: updated_at
    }
  end
end