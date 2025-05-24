# frozen_string_literal: true

class ProjectsIndexHandler < MK::Handler
  handler do |r|
    include_stats = r.params['include_stats'] == 'true'
    
    {
      projects: model.map { |project| project.to_hash(include_stats: include_stats) },
      total: model.count
    }
  end
end