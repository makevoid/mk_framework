# frozen_string_literal: true

require 'sequel'
require 'sequel/extensions/migration'

module SampleDatabase
  def self.connect(root:, filename:)
    # Test runs never open DATABASE_URL or the development database.
    return Sequel.sqlite(max_connections: 1) if ENV['RACK_ENV'] == 'test'

    url = ENV.fetch('DATABASE_URL') { "sqlite://#{File.join(root, filename)}" }
    Sequel.connect(url, max_connections: Integer(ENV.fetch('DB_POOL_SIZE', '5')),
                   pool_timeout: Integer(ENV.fetch('DB_POOL_TIMEOUT', '5')))
  end

  def self.migrate(database, root:)
    Sequel::Migrator.run(database, File.join(root, 'db/migrations'))
  end
end
