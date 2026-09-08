# frozen_string_literal: true

require 'rake'
require_relative '../generator'

namespace :mk_framework do
  desc 'Generate an app (optional DESTINATION=/path/to/app and APP_SPEC for non-interactive input)'
  task :init do
    arguments = ENV['DESTINATION'] ? [ENV.fetch('DESTINATION')] : []
    arguments += ['--cli', ENV.fetch('APP_SPEC')] if ENV['APP_SPEC']
    abort 'App generation did not complete.' unless MK::Generator::CLI.run(arguments).zero?
  end
end
