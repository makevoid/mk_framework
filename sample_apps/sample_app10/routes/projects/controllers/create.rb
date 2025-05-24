# frozen_string_literal: true

class ProjectsCreateController < MK::Controller
  route do |r|
    project = Project.new(
      name: r.params['name'],
      description: r.params['description'],
      status: r.params['status'] || 'active',
      start_date: r.params['start_date'],
      end_date: r.params['end_date'],
      owner_id: r.params['owner_id']
    )
    
    if project.valid?
      project.save
    end
    
    project
  end
end