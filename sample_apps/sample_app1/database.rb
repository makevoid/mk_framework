# frozen_string_literal: true

require_relative '../support/database'

module SampleApp1
  ROOT = __dir__.freeze
  DB = SampleDatabase.connect(root: ROOT, filename: 'todos.db')
end
