# frozen_string_literal: true

class User < Sequel::Model
  plugin :validation_helpers
  
  one_to_many :owned_projects, class: :Project, key: :owner_id
  one_to_many :assigned_tasks, class: :Task, key: :assigned_to_id
  one_to_many :created_tasks, class: :Task, key: :created_by_id
  one_to_many :comments
  
  def validate
    super
    validates_presence [:name, :email, :password_hash]
    validates_unique :email
    validates_format /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i, :email
    validates_includes ['admin', 'manager', 'member'], :role
  end
  
  def password=(password)
    self.password_hash = BCrypt::Password.create(password)
  end
  
  def authenticate(password)
    BCrypt::Password.new(password_hash) == password
  end
  
  def to_hash
    {
      id: id,
      name: name,
      email: email,
      role: role,
      active: active,
      created_at: created_at,
      updated_at: updated_at
    }
  end
end