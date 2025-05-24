# frozen_string_literal: true

class Comment < Sequel::Model
  plugin :validation_helpers
  
  many_to_one :task
  many_to_one :user
  
  def validate
    super
    validates_presence [:content, :task_id, :user_id]
    validates_min_length 1, :content
  end
  
  def to_hash
    {
      id: id,
      content: content,
      task_id: task_id,
      user_id: user_id,
      user: user ? { id: user.id, name: user.name } : nil,
      created_at: created_at,
      updated_at: updated_at
    }
  end
end