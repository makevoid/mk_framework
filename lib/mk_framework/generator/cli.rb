# frozen_string_literal: true

require 'shellwords'
require 'optparse'

module MK
  module Generator
    class CLI
      class Cancelled < StandardError; end

      def self.run(argv = ARGV, input: $stdin, output: $stdout)
        new(input: input, output: output).run(argv)
      end

      def initialize(input:, output:)
        @input, @output = input, output
      end

      def run(argv)
        arguments = argv.dup
        inline = nil
        help = false
        parser = OptionParser.new do |options|
          options.banner = 'Usage: mk_frame_init [DESTINATION] [--cli SPEC]'
          options.on('--cli SPEC', 'Generate without prompts: app_name:blog, model_name:posts, fields:[title:string]') { |value| inline = value }
          options.on('-h', '--help', 'Show usage') { help = true }
        end
        parser.parse!(arguments)
        if help
          @output.puts parser
          @output.puts 'Types: ' + Configuration::TYPES.keys.join(', ')
          return 0
        end
        raise InvalidInput, parser.banner if arguments.length > 1
        if inline
          config = Options.parse(inline)
          return generate(config, arguments.first || config.app_name)
        end

        @output.puts 'MK app generator — one model and a full CRUD resource with controllers and handlers.'
        @output.puts 'Press Ctrl-C to cancel. All fields are required; id and timestamps are automatic.'
        app = validated('1. App name (snake_case)') { |value| Configuration.app_name!(value) }
        model = validated('2. Model name (singular snake_case)') { |value| Configuration.model_name!(value) }
        resource = validated('3. Resource/table name (plural snake_case)', default: Naming.plural(model)) do |value|
          Configuration.identifier!(value, label: 'Resource name')
        end
        fields = collect_fields
        config = Configuration.new(app_name: app, model_name: model, resource: resource, fields: fields)
        destination = File.expand_path(arguments.first || app)
        @output.puts "\nApp: #{config.namespace}; model: #{config.model_class}; resource: /#{resource} (index, show, create, update, delete)"
        @output.puts "Fields: #{fields.map { |field| "#{field[:name]}:#{field[:type]}" }.join(', ')}"
        @output.puts "Directory: #{destination}"
        answer = validated('5. Generate these files? (y/n)', default: 'y') do |value|
          raise InvalidInput, 'Enter y or n.' unless %w[y n yes no].include?(value.downcase)
          value.downcase
        end
        raise Cancelled if %w[n no].include?(answer)
        generate(config, destination)
      rescue Cancelled, Interrupt
        @output.puts "\nCancelled."
        1
      rescue InvalidInput, OptionParser::ParseError, SystemCallError => error
        @output.puts "Error: #{error.message}"
        1
      end

      private

      def generate(config, destination)
        destination = Project.new(config).generate(destination)
        @output.puts "\nCreated #{destination}\nNext steps:"
        @output.puts "  cd #{Shellwords.escape(destination)}"
        @output.puts "  bundle install\n  bundle exec rake db:migrate\n  bundle exec rake routes\n  bundle exec rspec\n  bundle exec rake"
        0
      end

      def ask(prompt, default: nil)
        @output.print "#{prompt}#{default ? " [#{default}]" : ''}: "
        @output.flush
        line = @input.gets
        raise Cancelled unless line
        value = line.strip
        value.empty? && default ? default : value
      end

      def validated(prompt, default: nil)
        loop do
          value = ask(prompt, default: default)
          begin
            return yield(value)
          rescue InvalidInput => error
            @output.puts error.message
          end
        end
      end

      def collect_fields
        fields = []
        @output.puts '4. Add fields. Leave the next field name blank when finished.'
        loop do
          name = validated('Field name') do |value|
            if value.empty?
              raise InvalidInput, 'Add at least one field.' if fields.empty?
            else
              Configuration.field!(value, 'string')
              raise InvalidInput, 'That field already exists.' if fields.any? { |field| field[:name] == value }
            end
            value
          end
          break if name.empty?
          types = Configuration::TYPES.keys
          @output.puts types.each_with_index.map { |type, index| "  #{index + 1}. #{type}" }.join("\n")
          type = validated('Type (number or name)', default: 'string') do |value|
            selected = value.match?(/\A[1-9][0-9]*\z/) ? types[value.to_i - 1] : value
            raise InvalidInput, 'Choose a listed type.' unless types.include?(selected)
            selected
          end
          fields << {name: name, type: type}
        end
        fields
      end
    end
  end
end
