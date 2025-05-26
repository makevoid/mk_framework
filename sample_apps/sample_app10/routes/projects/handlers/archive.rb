# frozen_string_literal: true

# FIXME

class ProjectsArchiveHandler < MK::Handler
  handler do |r|
    {
      message: "Project archived successfully",
      project: model.to_hash(include_stats: true)
    }
  end
end