# frozen_string_literal: true

class TasksIndexHandler < MK::Handler
  handler do |r|
    include_associations = r.params['include_associations'] == 'true'
    
    {
      tasks: model.map { |task| task.to_hash(include_associations: include_associations) },
      total: model.count
    }
  end
end