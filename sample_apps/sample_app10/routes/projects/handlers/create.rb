# frozen_string_literal: true

class ProjectsCreateHandler < MK::Handler
  handler do |r|
    success do |r|
      r.response.status = 201
      {
        message: "Project created successfully",
        project: model.to_hash(include_stats: true)
      }
    end
    
    error do |r|
      r.response.status = 422
      {
        error: "Failed to create project",
        details: model.errors
      }
    end
  end
end