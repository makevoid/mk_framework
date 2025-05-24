# frozen_string_literal: true

class ProjectsShowHandler < MK::Handler
  handler do |r|
    model.to_hash(include_stats: true)
  end
end