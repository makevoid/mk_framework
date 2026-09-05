# frozen_string_literal: true

require 'rake'
require 'rbconfig'

module SampleTasks
  extend Rake::DSL
  def self.install(root)
    namespace :db do
      desc 'Apply database migrations (DATABASE_URL or the local SQLite database)'
      task :migrate do
        require File.join(root, 'database')
        number = File.basename(root).delete_prefix('sample_app')
        database = Object.const_get("SampleApp#{number}").const_get(:DB)
        SampleDatabase.migrate(database, root: root)
      end
    end

    desc 'Run isolated request specs and boot checks'
    task :spec do
      sh RbConfig.ruby, '-S', 'rspec', File.join(root, 'spec')
    end

    desc 'Print the compiled resource routes'
    task :routes do
      require File.join(root, 'app')
      number = File.basename(root).delete_prefix('sample_app')
      puts Object.const_get("SampleApp#{number}").const_get(:App).route_table
    end

    task default: :spec
  end
end
