# frozen_string_literal: true

require_relative '../support/database'

module SampleApp7
  ROOT = __dir__.freeze
  DB = SampleDatabase.connect(root: ROOT, filename: 'kanban7.db')
end
