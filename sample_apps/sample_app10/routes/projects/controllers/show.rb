# frozen_string_literal: true

class ProjectsShowController < MK::Controller
  route do |r|
    project = Project[r.params.fetch('id')]
    r.halt(404, { error: "Project not found" }) if project.nil?
    
    project
  end
end