# frozen_string_literal: true

class Task < Sequel::Model
  plugin :validation_helpers
  
  many_to_one :project
  many_to_one :assigned_to, class: :User
  many_to_one :created_by, class: :User
  one_to_many :comments
  
  def validate
    super
    validates_presence [:title, :project_id, :created_by_id]
    validates_includes ['todo', 'in_progress', 'review', 'done'], :status
    validates_includes ['low', 'medium', 'high', 'critical'], :priority
  end
  
  def before_save
    if status_changed? && status == 'done' && !completed_at
      self.completed_at = Time.now
    elsif status_changed? && status != 'done'
      self.completed_at = nil
    end
    super
  end
  
  def overdue?
    due_date && due_date < Date.today && status != 'done'
  end
  
  def to_hash(include_associations: false)
    hash = {
      id: id,
      title: title,
      description: description,
      status: status,
      priority: priority,
      project_id: project_id,
      assigned_to_id: assigned_to_id,
      created_by_id: created_by_id,
      due_date: due_date,
      estimated_hours: estimated_hours,
      actual_hours: actual_hours,
      completed_at: completed_at,
      overdue: overdue?,
      created_at: created_at,
      updated_at: updated_at
    }
    
    if include_associations
      hash[:project] = project.to_hash if project
      hash[:assigned_to] = assigned_to.to_hash if assigned_to
      hash[:created_by] = created_by.to_hash if created_by
      hash[:comments_count] = comments.count
    end
    
    hash
  end
end