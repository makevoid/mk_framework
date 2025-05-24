# frozen_string_literal: true

class ProjectsUpdateController < MK::Controller
  route do |r|
    project = Project[r.params.fetch('id')]
    r.halt(404, { error: "Project not found" }) if project.nil?
    
    project.update(
      name: r.params['name'] || project.name,
      description: r.params.key?('description') ? r.params['description'] : project.description,
      status: r.params['status'] || project.status,
      start_date: r.params.key?('start_date') ? r.params['start_date'] : project.start_date,
      end_date: r.params.key?('end_date') ? r.params['end_date'] : project.end_date,
      owner_id: r.params['owner_id'] || project.owner_id
    )
    
    project
  end
end