# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Boot loading' do
  it 'loads action files relative to root rather than the process directory' do
    Dir.mktmpdir('mk-loading') do |root|
      namespace = Module.new
      stub_const('LoadingExample', namespace)
      FileUtils.mkdir_p(File.join(root, 'routes/widgets/controllers'))
      FileUtils.mkdir_p(File.join(root, 'routes/widgets/handlers'))
      File.write(File.join(root, 'routes/widgets/controllers/base.rb'), '# Shared controller helpers are not endpoints')
      File.write(File.join(root, 'routes/widgets/controllers/index.rb'), <<~CODE)
        module LoadingExample
          class WidgetsIndexController < MK::Controller
            route { |_r| {loaded: true} }
          end
        end
      CODE
      File.write(File.join(root, 'routes/widgets/handlers/index.rb'), <<~CODE)
        module LoadingExample
          class WidgetsIndexHandler < MK::Handler
            route { |_r| model }
          end
        end
      CODE
      app = Class.new(MK::Application)
      app.configure(root: root, namespace: namespace)
      Dir.chdir('/') { app.boot! }
      expect(body(request(app, 'GET', '/widgets'))).to eq('loaded' => true)
      expect(request(app, 'POST', '/widgets').status).to eq(405)
    end
  end

  it 'can mount another Rack application without replacing resource routes' do
    child = ->(_env) { [200, {'content-type' => 'text/plain'}, ['mounted']] }
    space = Module.new
    action(space, :widgets, :index) { |_r| {ok: true} }
    app = build_app(namespace: space, routes: proc { resources :widgets, only: [:index] },
                    custom: proc { |r| r.on('other') { r.run(child) } })
    expect(request(app, 'GET', '/other').body).to eq('mounted')
    expect(body(request(app, 'GET', '/widgets'))).to eq('ok' => true)
  end
end
