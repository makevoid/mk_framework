# frozen_string_literal: true

require 'erb'
require 'fileutils'
require 'json'
require_relative '../version'

module MK
  module Generator
    class Project
      TEMPLATES = {
        'Gemfile' => 'Gemfile', 'Rakefile' => 'Rakefile', 'gitignore' => '.gitignore',
        'README.md' => 'README.md', 'app.rb' => 'app.rb', 'config.ru' => 'config.ru',
        'database.rb' => 'database.rb', 'migration.rb' => 'db/migrations/001_initial.rb',
        'model.rb' => 'models/%{model}.rb',
        'spec_helper.rb' => 'spec/spec_helper.rb', 'request_spec.rb' => 'spec/request/%{resource}_spec.rb'
      }.freeze

      def initialize(configuration)
        @configuration = configuration
      end

      def generate(destination)
        destination = File.expand_path(destination)
        raise InvalidInput, 'Destination already exists; choose a new directory.' if File.exist?(destination) || File.symlink?(destination)
        parent = File.dirname(destination)
        raise InvalidInput, 'Destination parent directory does not exist.' unless File.directory?(parent)

        # Render before touching the destination, then reserve it without overwriting anything.
        files = render
        Dir.mkdir(destination)
        files.each do |relative, content|
          target = File.join(destination, relative)
          FileUtils.mkdir_p(File.dirname(target))
          File.write(target, content, mode: 'wx')
        end
        destination
      rescue Errno::EEXIST
        raise InvalidInput, 'Destination already exists; choose a new directory.'
      end

      def render
        config = @configuration
        files = TEMPLATES.to_h do |template, path|
          source = File.read(File.join(__dir__, 'templates', "#{template}.erb"))
          [format(path, model: config.model_name, resource: config.resource), ERB.new(source, trim_mode: '-').result(binding)]
        end
        Configuration::ACTIONS.each do |action|
          %w[controller handler].each do |kind|
            source = File.read(File.join(__dir__, 'templates', "#{kind}.rb.erb"))
            files["routes/#{config.resource}/#{kind}s/#{action}.rb"] = ERB.new(source, trim_mode: '-').result(binding)
          end
        end
        files
      end
    end
  end
end
