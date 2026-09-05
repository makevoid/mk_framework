# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../sample_apps/support/test_runner'

RSpec.describe SampleTestRunner do
  it 'propagates a failing child process to the aggregate task' do
    directory = File.expand_path('..', __dir__)
    expect { described_class.run([directory], command: [RbConfig.ruby, '-e', 'exit 0']) }.not_to raise_error
    expect { described_class.run([directory], command: [RbConfig.ruby, '-e', 'exit 7']) }
      .to raise_error(RuntimeError, /Sample suites failed/)
  end

  it 'isolates the child lockfile as well as its Gemfile under Bundler 4' do
    directory = File.expand_path('../sample_apps/sample_app1', __dir__)
    check = "exit(ENV.fetch('BUNDLE_LOCKFILE') == File.join(Dir.pwd, 'Gemfile.lock') ? 0 : 1)"
    expect { described_class.run([directory], command: [RbConfig.ruby, '-e', check]) }.not_to raise_error
  end
end
