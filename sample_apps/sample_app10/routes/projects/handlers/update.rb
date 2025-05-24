# frozen_string_literal: true

class ProjectsUpdateHandler < MK::Handler
  handler do |r|
    success do |r|
      {
        message: "Project updated successfully",
        project: model.to_hash(include_stats: true)
      }
    end
    
    error do |r|
      r.response.status = 422
      {
        error: "Failed to update project",
        details: model.errors
      }
    end
  end
end