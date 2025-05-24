# frozen_string_literal: true

class Order < Sequel::Model
  plugin :validation_helpers
  
  many_to_one :cart

  def validate
    super
    validates_presence [:total, :customer_email, :customer_name, :shipping_address]
    validates_format /\A[^@\s]+@[^@\s]+\z/, :customer_email
    validates_numeric :total
    validates_operator(:>, 0, :total)
    validates_includes ['pending', 'processing', 'shipped', 'delivered', 'cancelled'], :status
  end

  def before_create
    self.order_number ||= generate_order_number
    super
  end

  def to_hash
    {
      id: id,
      order_number: order_number,
      total: total.to_f,
      status: status,
      customer_email: customer_email,
      customer_name: customer_name,
      shipping_address: shipping_address,
      payment_method: payment_method,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  private

  def generate_order_number
    "ORD-#{Time.now.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end
end