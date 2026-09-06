# frozen_string_literal: true

require 'rspec/core/rake_task'
require_relative 'sample_apps/support/test_runner'
require_relative 'lib/mk_framework/version'

RSpec::Core::RakeTask.new(:spec)

desc 'Test every sample app in a separate process with its own bundle'
task :samples do
  SampleTestRunner.run(Dir[File.join(__dir__, 'sample_apps/sample_app[0-9]*')].sort)
end

desc 'Build the release gem in pkg/'
task :build do
  mkdir_p File.join(__dir__, 'pkg')
  sh RbConfig.ruby, '-S', 'gem', 'build', File.join(__dir__, 'mk_framework.gemspec'),
     '--output', File.join(__dir__, 'pkg', "mk_framework-#{MK::VERSION}.gem")
end

task default: %i[spec samples]
