# frozen_string_literal: true

require_relative '../support/database'

module SampleApp6
  ROOT = __dir__.freeze
  DB = SampleDatabase.connect(root: ROOT, filename: 'weather.db')
end
