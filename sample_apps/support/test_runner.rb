# frozen_string_literal: true

require 'rbconfig'

module SampleTestRunner
  def self.run(directories, command: [RbConfig.ruby, '-S', 'bundle', 'exec', 'rspec'])
    failures = directories.reject do |directory|
      puts "Testing #{File.basename(directory)}"
      environment = {
        'BUNDLE_GEMFILE' => File.join(directory, 'Gemfile'),
        'BUNDLE_LOCKFILE' => File.join(directory, 'Gemfile.lock')
      }
      if defined?(Bundler) && Bundler.settings[:path]
        environment['BUNDLE_PATH'] = File.expand_path(Bundler.settings[:path], Bundler.root)
      end
      system(environment, *command, chdir: directory)
    end
    raise "Sample suites failed: #{failures.map { |directory| File.basename(directory) }.join(', ')}" unless failures.empty?
  end
end
