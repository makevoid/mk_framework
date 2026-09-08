# frozen_string_literal: true

require 'rspec/core/rake_task'
require_relative 'lib/mk_framework/version'

RSpec::Core::RakeTask.new(:spec)

desc 'Build the release gem in pkg/'
task :build do
  mkdir_p File.join(__dir__, 'pkg')
  sh RbConfig.ruby, '-S', 'gem', 'build', File.join(__dir__, 'mk_framework.gemspec'),
     '--output', File.join(__dir__, 'pkg', "mk_framework-#{MK::VERSION}.gem")
end

task default: :spec
