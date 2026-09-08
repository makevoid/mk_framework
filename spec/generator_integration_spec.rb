# frozen_string_literal: true

require_relative 'spec_helper'
require 'mk_framework/generator'
require 'open3'
require 'rbconfig'
require 'socket'
require 'net/http'
require 'timeout'

RSpec.describe 'Generated applications' do
  let(:root) { File.expand_path('..', __dir__) }
  let(:all_types) do
    'app_name:generated_blog, model_name:posts, fields:[title:string, contents:text, quantity:integer, price:float, published:boolean, starts_on:date, scheduled_at:datetime]'
  end

  def execute(*command, environment: {}, directory:)
    output, status = Open3.capture2e(environment, RbConfig.ruby, *command, chdir: directory)
    expect(status.success?).to eq(true), output
    output
  end

  it 'generates an app via CLI, runs its request specs, and preserves a private test database' do
    Dir.mktmpdir do |directory|
      app = File.join(directory, 'generated_blog')
      execute('-I', File.join(root, 'lib'), File.join(root, 'bin/mk_frame_init'), '--cli', all_types, app, directory: directory)
      protected_database = File.join(directory, 'do-not-open.db')
      File.write(protected_database, 'untouched')
      output = execute('-S', 'rspec', File.join(app, 'spec'),
        environment: {'DATABASE_URL' => "sqlite://#{protected_database}"}, directory: directory)
      expect(output).to include('13 examples, 0 failures')
      expect(File.read(protected_database)).to eq('untouched')
      expect(File.exist?(File.join(app, 'generated_blog.db'))).to eq(false)
    end
  end

  it 'migrates idempotently, boots from another directory, and round-trips every supported type' do
    Dir.mktmpdir do |directory|
      app = File.join(directory, 'generated_blog')
      config = MK::Generator::Options.parse(all_types)
      MK::Generator::Project.new(config).generate(app)
      environment = {'RACK_ENV' => 'production', 'DATABASE_URL' => "sqlite://#{File.join(directory, 'production.db')}"}
      2.times { execute('-S', 'rake', 'db:migrate', environment: environment, directory: app) }
      expect(execute('-S', 'rake', 'routes', environment: environment, directory: app)).to include('POST   /posts')
      code = <<~CODE
        require 'rack/builder'
        require 'rack/test'
        require 'json'
        app = Rack::Builder.parse_file(#{File.join(app, 'config.ru').inspect})
        client = Rack::Test::Session.new(app)
        attributes = JSON.parse(#{JSON.generate(config.example).inspect})
        response = client.post('/posts', JSON.generate(attributes), 'CONTENT_TYPE' => 'application/json')
        abort response.body unless response.status == 201
        row = GeneratedBlog::Post.first
        raise row.inspect unless row.title == 'Example' && row.contents == 'Example text' && row.quantity == 1 && row.price == 1.5 && row.published == false
        raise row.inspect unless row.starts_on == Date.new(2026, 1, 1) && row.scheduled_at.year == 2026
        raise unless GeneratedBlog::App.router.endpoints.length == 6
        raise unless client.get('/posts').status == 200
        %w[starts_on scheduled_at].each do |field|
          response = client.post('/posts', JSON.generate(attributes.merge(field => 'not-a-date')), 'CONTENT_TYPE' => 'application/json')
          raise response.body unless response.status == 400 && GeneratedBlog::Post.count == 1
        end
        GeneratedBlog::DB.disconnect
      CODE
      execute('-e', code, environment: environment, directory: directory)
    end
  end

  MK::Generator::Configuration::TYPES.each_key do |type|
    it "generates working CRUD request specs for a #{type} field" do
      Dir.mktmpdir do |directory|
        app = File.join(directory, 'typed_app')
        config = MK::Generator::Options.parse("app_name:typed_app, model_name:entry, fields:[value:#{type}]")
        MK::Generator::Project.new(config).generate(app)
        expect(execute('-S', 'rake', 'spec', environment: {'TZ' => 'Europe/Zurich'}, directory: app)).to include('13 examples, 0 failures')
      end
    end
  end

  it 'makes default rake and rake dev start Puma on port 3000' do
    Dir.mktmpdir do |directory|
      app = File.join(directory, 'generated_blog')
      MK::Generator::Project.new(MK::Generator::Options.parse(all_types)).generate(app)
      %w[default dev].each do |task|
        code = <<~CODE
          require 'rake'
          require 'json'
          load #{File.join(app, 'Rakefile').inspect}
          def exec(*arguments, **options)
            puts JSON.generate(arguments: arguments, options: options)
          end
          Rake::Task[#{task.inspect}].invoke
        CODE
        command = JSON.parse(execute('-e', code, environment: {'HOST' => nil, 'PORT' => nil}, directory: directory))
        expect(command.fetch('arguments')).to eq([RbConfig.ruby, '-S', 'puma', '--bind', 'tcp://127.0.0.1:3000', File.realpath(File.join(app, 'config.ru'))])
        expect(command.fetch('options')).to eq('chdir' => File.realpath(app))
      end
    end
  end

  it 'serves the generated app through plain rake with Puma and a configured port' do
    Dir.mktmpdir do |directory|
      app = File.join(directory, 'generated_blog')
      MK::Generator::Project.new(MK::Generator::Options.parse(all_types)).generate(app)
      environment = {'RACK_ENV' => 'development', 'DATABASE_URL' => "sqlite://#{File.join(directory, 'server.db')}"}
      execute('-S', 'rake', 'db:migrate', environment: environment, directory: app)
      port = TCPServer.open('127.0.0.1', 0) { |socket| socket.addr[1] }
      log = File.join(directory, 'puma.log')
      pid = Process.spawn(environment.merge('PORT' => port.to_s, 'HOST' => '127.0.0.1'), RbConfig.ruby, '-S', 'rake', chdir: app, out: log, err: [:child, :out])
      begin
        response = Timeout.timeout(15) do
          loop do
            begin
              break Net::HTTP.get_response(URI("http://127.0.0.1:#{port}/posts"))
            rescue Errno::ECONNREFUSED
              raise File.read(log) if Process.waitpid(pid, Process::WNOHANG)
              sleep 0.05
            end
          end
        end
        expect(response.code).to eq('200'), File.read(log)
        expect(JSON.parse(response.body)).to eq('posts' => [])
      ensure
        Process.kill('TERM', pid) rescue Errno::ESRCH
        Process.waitpid(pid) rescue Errno::ECHILD
      end
    end
  end

  it 'exposes a Rake task with the same non-interactive generator' do
    Dir.mktmpdir do |directory|
      target = File.join(directory, 'from_rake')
      execute('-S', 'rake', 'mk_framework:init', environment: {'APP_SPEC' => all_types, 'DESTINATION' => target}, directory: root)
      expect(File.file?(File.join(target, 'models/post.rb'))).to eq(true)
    end
  end

  it 'boots when the app namespace and model share a name' do
    Dir.mktmpdir do |directory|
      app = File.join(directory, 'post')
      config = MK::Generator::Options.parse('app_name:post, model_name:post, fields:[title:string]')
      MK::Generator::Project.new(config).generate(app)
      output = execute('-S', 'rspec', File.join(app, 'spec'), directory: directory)
      expect(output).to include('13 examples, 0 failures')
    end
  end

  it 'ships templates and a working executable in the installable gem' do
    Dir.mktmpdir do |directory|
      package = File.join(directory, 'mk_framework.gem')
      gems = File.join(directory, 'gems')
      execute('-S', 'gem', 'build', File.join(root, 'mk_framework.gemspec'), '--output', package, directory: root)
      execute('-S', 'gem', 'install', '--local', '--ignore-dependencies', '--no-document', '--install-dir', gems, package, directory: directory)
      environment = {'RUBYOPT' => nil, 'RUBYLIB' => nil, 'BUNDLE_GEMFILE' => nil, 'BUNDLE_BIN_PATH' => nil,
        'GEM_HOME' => gems, 'GEM_PATH' => ([gems] + Gem.path).join(File::PATH_SEPARATOR)}
      output = execute(File.join(gems, 'bin/mk_frame_init'), '--cli', all_types,
        environment: environment, directory: directory)
      expect(output).to include('Created')
      %w[index show create update delete].product(%w[controllers handlers]).each do |action, kind|
        expect(File.file?(File.join(directory, "generated_blog/routes/posts/#{kind}/#{action}.rb"))).to eq(true)
      end
    end
  end
end
