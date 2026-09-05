# frozen_string_literal: true

require_relative 'spec_helper'
require 'open3'
require 'rbconfig'

RSpec.describe 'Sample deployment lifecycle' do
  it 'migrates and boots every real entrypoint using fresh on-disk databases in production mode' do
    root = File.expand_path('..', __dir__)
    Dir.mktmpdir('mk-deployment') do |directory|
      (1..6).each do |number|
        sample = File.join(root, "sample_apps/sample_app#{number}")
        environment = {
          'RACK_ENV' => 'production',
          'DATABASE_URL' => "sqlite://#{File.join(directory, "sample#{number}.db")}",
          'BUNDLE_GEMFILE' => File.join(root, 'Gemfile'),
          'BUNDLE_LOCKFILE' => File.join(root, 'Gemfile.lock')
        }
        2.times do
          output, status = Open3.capture2e(environment, RbConfig.ruby, '-S', 'rake', 'db:migrate', chdir: sample)
          expect(status.success?).to eq(true), output
        end
        resource = {1 => 'todos', 2 => 'todos', 3 => 'todos', 4 => 'posts', 5 => 'cards', 6 => 'weather'}.fetch(number)
        code = <<~CODE
          require 'rack/builder'
          require 'rack/mock'
          app = Rack::Builder.parse_file(#{File.join(sample, 'config.ru').inspect})
          response = Rack::MockRequest.new(app).get('/#{resource}')
          abort response.body unless response.status == 200 && response.content_type == 'application/json'
        CODE
        output, status = Open3.capture2e(environment, RbConfig.ruby, '-e', code, chdir: directory)
        expect(status.success?).to eq(true), output
      end
    end
  end

  it 'loads real applications together without model, database, or action constant collisions' do
    root = File.expand_path('..', __dir__)
    code = <<~CODE
      require 'rack/mock'
      root = #{root.inspect}
      [1, 2, 4, 5].each do |number|
        require File.join(root, "sample_apps/sample_app\#{number}/database")
        namespace = Object.const_get("SampleApp\#{number}")
        SampleDatabase.migrate(namespace::DB, root: namespace::ROOT)
        require File.join(namespace::ROOT, 'app')
      end
      SampleApp1::Todo.create(title: 'one')
      SampleApp2::Todo.create(title: 'two')
      raise unless SampleApp1::Todo.first.title == 'one' && SampleApp2::Todo.first.title == 'two'
      post = SampleApp4::Post.create(title: 'blog')
      card = SampleApp5::Card.create(title: 'kanban')
      SampleApp4::Comment.create(post_id: post.id, content: 'blog comment')
      SampleApp5::Comment.create(card_id: card.id, content: 'card comment')
      raise unless post.comments.first.content == 'blog comment'
      raise unless card.comments.first.content == 'card comment'
      [[SampleApp4::App, '/posts/1/comments', 'blog comment'], [SampleApp5::App, '/cards/1/comments', 'card comment']].each do |app, path, content|
        response = Rack::MockRequest.new(app.app).get(path)
        raise response.body unless response.status == 200 && JSON.parse(response.body).first.fetch('content') == content
      end
    CODE
    output, status = Open3.capture2e({'RACK_ENV' => 'test'}, RbConfig.ruby, '-e', code)
    expect(status.success?).to eq(true), output
  end
end
