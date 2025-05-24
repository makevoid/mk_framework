# frozen_string_literal: true

class User < Sequel::Model
  plugin :validation_helpers
  plugin :timestamps
  
  one_to_many :cart_items
  one_to_many :orders
  
  def validate
    super
    validates_presence [:email, :password_hash, :first_name, :last_name]
    validates_unique :email
    validates_format /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i, :email
    validates_max_length 100, :first_name
    validates_max_length 100, :last_name
    validates_max_length 255, :email
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def cart_total
    cart_items.sum { |item| item.quantity * item.product.price }
  end
  
  def cart_items_count
    cart_items.sum(:quantity)
  end
  
  # Hide password_hash from JSON output
  def to_hash
    super.except(:password_hash)
  end
end