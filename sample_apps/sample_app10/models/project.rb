# frozen_string_literal: true

class Project < Sequel::Model
  plugin :validation_helpers
  
  many_to_one :owner, class: :User
  one_to_many :tasks
  
  def validate
    super
    validates_presence [:name, :owner_id]
    validates_includes ['active', 'completed', 'archived', 'on_hold'], :status
  end
  
  def active_tasks
    tasks_dataset.where(status: ['todo', 'in_progress', 'review'])
  end
  
  def completed_tasks
    tasks_dataset.where(status: 'done')
  end
  
  def task_statistics
    {
      total: tasks.count,
      todo: tasks_dataset.where(status: 'todo').count,
      in_progress: tasks_dataset.where(status: 'in_progress').count,
      review: tasks_dataset.where(status: 'review').count,
      done: tasks_dataset.where(status: 'done').count
    }
  end
  
  def to_hash(include_stats: false)
    hash = {
      id: id,
      name: name,
      description: description,
      status: status,
      start_date: start_date,
      end_date: end_date,
      owner_id: owner_id,
      archived: archived,
      created_at: created_at,
      updated_at: updated_at
    }
    
    if include_stats
      hash[:task_statistics] = task_statistics
      hash[:owner] = owner.to_hash if owner
    end
    
    hash
  end
end