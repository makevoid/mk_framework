# frozen_string_literal: true

class ProjectsDeleteHandler < MK::Handler
  handler do |r|
    {
      message: "Project deleted successfully",
      project: model.to_hash
    }
  end
end