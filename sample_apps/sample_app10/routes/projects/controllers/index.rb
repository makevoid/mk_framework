# frozen_string_literal: true

class ProjectsIndexController < MK::Controller
  route do |r|
    projects = Project.where(archived: false)
    
    # Filter by status if provided
    if r.params['status']
      projects = projects.where(status: r.params['status'])
    end
    
    # Filter by owner if provided
    if r.params['owner_id']
      projects = projects.where(owner_id: r.params['owner_id'])
    end
    
    # Include statistics if requested
    include_stats = r.params['include_stats'] == 'true'
    
    projects.all
  end
end