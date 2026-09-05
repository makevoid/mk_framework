# frozen_string_literal: true

require_relative '../support/database'

module SampleApp5
  ROOT = __dir__.freeze
  DB = SampleDatabase.connect(root: ROOT, filename: 'kanban2.db')
end
