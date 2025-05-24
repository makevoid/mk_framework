# frozen_string_literal: true

class ProjectsDeleteController < MK::Controller
  route do |r|
    project = Project[r.params.fetch('id')]
    r.halt(404, { error: "Project not found" }) if project.nil?
    
    project.destroy
    project
  end
end