# frozen_string_literal: true

require_relative 'spec_helper'
require 'mk_framework/generator'
require 'open3'
require 'rbconfig'

RSpec.describe MK::Generator do
  let(:specification) { 'app_name:blog, model_name:posts, fields:[title:string, contents:text]' }
  let(:configuration) { MK::Generator::Options.parse(specification) }

  describe MK::Generator::Options do
    it 'parses whitespace, plural models, explicit resources, and all field types' do
      fields = MK::Generator::Configuration::TYPES.keys.map { |type| "field_#{type}:#{type}" }.join(', ')
      config = described_class.parse(" app_name:my_blog, model_name:people, resource_name:authors, fields:[#{fields}] ")
      expect(config.namespace).to eq('MyBlog')
      expect(config.model_class).to eq('Person')
      expect(config.resource).to eq('authors')
      expect(config.fields.map { |field| field[:type] }).to eq(MK::Generator::Configuration::TYPES.keys)
    end

    it 'supports singular model names and conventional plural resources' do
      {'post' => 'posts', 'category' => 'categories', 'status' => 'statuses'}.each do |model, resource|
        config = described_class.parse("app_name:blog, model_name:#{model}, fields:[title:string]")
        expect(config.model_name).to eq(model)
        expect(config.resource).to eq(resource)
      end
    end

    [
      'app_name:blog, model_name:posts',
      'app_name:blog, model_name:posts, fields:[]',
      'app_name:blog, model_name:posts, fields:[title:unknown]',
      'app_name:blog, model_name:posts, fields:[title:string,title:text]',
      'app_name:blog, model_name:posts, fields:[id:integer]',
      'app_name:blog, model_name:posts, fields:[save:string]',
      'app_name:blog, model_name:posts, fields:[before_save:string]',
      'app_name:blog, model_name:posts, fields:[class:string]',
      'app_name:blog, model_name:app, fields:[title:string]',
      'app_name:string, model_name:posts, fields:[title:string]',
      'app_name:blog, model_name:string, fields:[title:string]',
      'app_name:../../outside, model_name:posts, fields:[title:string]',
      'app_name:blog, app_name:other, model_name:posts, fields:[title:string]',
      'app_name:blog, model_name:posts, fields:[title:string], extra:ignored',
      'app_name:blog, model_name:posts, fields:[title:string],',
      'app_name:blog, model_name:posts, fields:[title:string,]',
      'app_name:blog, model_name:posts, fields:[title:string]; Kernel.exit'
    ].each do |input|
      it "rejects malformed or unsafe configuration #{input.inspect}" do
        expect { described_class.parse(input) }.to raise_error(MK::Generator::InvalidInput)
      end
    end
  end

  describe MK::Generator::Project do
    it 'creates exactly one model, controller, and handler with local setup files' do
      Dir.mktmpdir do |directory|
        target = File.join(directory, 'blog')
        described_class.new(configuration).generate(target)
        expect(Dir[File.join(target, 'models/*.rb')].length).to eq(1)
        expect(Dir[File.join(target, 'routes/*/controllers/*.rb')].length).to eq(1)
        expect(Dir[File.join(target, 'routes/*/handlers/*.rb')].length).to eq(1)
        expect(File.read(File.join(target, '.gitignore'))).to include('.env.*')
        expect(File.read(File.join(target, 'app.rb'))).to include('only: [:create]')
        expect(Dir[File.join(target, '**/*')].select { |path| File.file?(path) }.map { |path| File.read(path) }.join).not_to include("../support/")
      end
    end

    it 'does not overwrite an existing directory or follow a destination symlink' do
      Dir.mktmpdir do |directory|
        sentinel = File.join(directory, 'keep.txt')
        File.write(sentinel, 'unchanged')
        expect { described_class.new(configuration).generate(directory) }.to raise_error(MK::Generator::InvalidInput, /already exists/)
        link = File.join(directory, 'link')
        File.symlink(File.join(directory, 'missing'), link)
        expect { described_class.new(configuration).generate(link) }.to raise_error(MK::Generator::InvalidInput, /already exists/)
        expect(File.read(sentinel)).to eq('unchanged')
        expect(File.exist?(File.join(directory, 'missing'))).to eq(false)
      end
    end
  end

  describe MK::Generator::CLI do
    it 'walks through prompts, retries invalid entries, and generates the selected field types' do
      Dir.mktmpdir do |directory|
        output = StringIO.new
        input = StringIO.new("../bad\nblog\npost\n\n\nid\ntitle\n99\n1\ntitle\ncontents\ntext\n\ny\n")
        status = described_class.run([File.join(directory, 'blog')], input: input, output: output)
        expect(status).to eq(0), output.string
        expect(output.string).to include('Choose a listed type.', 'That field already exists.', 'Created')
        expect(File.read(File.join(directory, 'blog/db/migrations/001_initial.rb'))).to include('String :contents, null: false, text: true')
      end
    end

    it 'cancels on EOF or a declined final prompt without creating files' do
      Dir.mktmpdir do |directory|
        [StringIO.new(''), StringIO.new("blog\npost\n\ntitle\n\n\nn\n")].each do |input|
          expect(described_class.run([File.join(directory, 'blog')], input: input, output: StringIO.new)).to eq(1)
          expect(File.exist?(File.join(directory, 'blog'))).to eq(false)
        end
      end
    end

    it 'generates through the executable with inline arguments and no stdin' do
      Dir.mktmpdir do |directory|
        output, status = run_bin('--cli', specification, 'my blog', directory: directory)
        expect(status.success?).to eq(true), output
        expect(output).to include('Created')
        expect(output).not_to include('Field name:')
        expect(File.file?(File.join(directory, 'my blog/config.ru'))).to eq(true)
        output, status = run_bin('--cli', specification, 'my blog', directory: directory)
        expect(status.exitstatus).to eq(1)
        expect(output).to include('already exists')
      end
    end

    it 'reports invalid flags and inline input with a failing exit code and no files' do
      Dir.mktmpdir do |directory|
        [['--unknown'], ['--cli'], ['--cli', 'app_name:bad'], ['one', 'two']].each do |arguments|
          output, status = run_bin(*arguments, directory: directory)
          expect(status.exitstatus).to eq(1), output
          expect(Dir.children(directory)).to be_empty
        end
        output, status = run_bin('--help', directory: directory)
        expect(status.success?).to eq(true)
        expect(output).to include('--cli', 'DESTINATION')
      end
    end
  end

  def run_bin(*arguments, directory:)
    root = File.expand_path('..', __dir__)
    Open3.capture2e(RbConfig.ruby, '-I', File.join(root, 'lib'), File.join(root, 'bin/mk_frame_init'),
      *arguments, stdin_data: '', chdir: directory)
  end
end
