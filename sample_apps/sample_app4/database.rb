# frozen_string_literal: true

require_relative '../support/database'

module SampleApp4
  ROOT = __dir__.freeze
  DB = SampleDatabase.connect(root: ROOT, filename: 'blog.db')
end
