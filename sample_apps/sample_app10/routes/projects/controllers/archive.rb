# frozen_string_literal: true

class ProjectsArchiveController < MK::Controller
  route do |r|
    project = Project[r.params.fetch('id')]
    r.halt(404, { error: "Project not found" }) if project.nil?
    
    project.update(archived: true)
    project
  end
end