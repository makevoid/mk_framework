# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Resource routing' do
  let(:space) { Module.new }

  before do
    %i[organizations projects comments].each do |resource|
      MK::Routes::ACTIONS.each_key do |name|
        action(space, resource, name) { |r| {action: name, path: r.path_params, params: r.params} }
      end
    end
  end

  it 'supports every CRUD action three levels deep and retains all ancestor IDs' do
    app = build_app(namespace: space, routes: proc {
      scope '/api/v1' do
        resources :organizations do
          resources :projects do
            resources :comments
          end
        end
      end
    })
    prefix = '/api/v1/organizations/one/projects/two/comments'
    {'GET' => :index, 'POST' => :create}.each do |verb, name|
      result = request(app, verb, prefix)
      expect(result.status).to eq(200)
      expect(body(result)).to include('action' => name.to_s, 'path' => {'organization_id' => 'one', 'project_id' => 'two'})
    end
    {'GET' => :show, 'PATCH' => :update, 'DELETE' => :delete}.each do |verb, name|
      result = request(app, verb, "#{prefix}/three")
      expect(result.status).to eq(200)
      expect(body(result)).to include('action' => name.to_s, 'path' => {'organization_id' => 'one', 'project_id' => 'two', 'id' => 'three'})
    end
    expect(request(app, 'POST', "#{prefix}/three").status).to eq(200)
    expect(request(app, 'POST', "#{prefix}/three/delete").status).to eq(200)
    expect(request(app, 'GET', "#{prefix}/three/extra").status).to eq(404)
  end

  it 'prevents query and JSON input from overriding path IDs without mutating input' do
    app = build_app(namespace: space, routes: proc { resources(:projects) { resources :comments } })
    result = body(request(app, 'PATCH', '/projects/url-parent/comments/url-child?id=query',
                          input: '{"project_id":"body-parent","id":"body-child"}'))
    expect(result['path']).to eq('project_id' => 'url-parent', 'id' => 'url-child')
    expect(result['params']).to include('project_id' => 'url-parent', 'id' => 'url-child')
    expect(app.router.endpoints).to be_frozen
  end

  it 'provides HEAD and 405 with an Allow header and can disable legacy POST aliases' do
    app = build_app(namespace: space, legacy_post_routes: false, routes: proc { resources :comments })
    result = request(app, 'HEAD', '/comments/1')
    expect(result.status).to eq(200)
    expect(result.body).to eq('')
    result = request(app, 'POST', '/comments/1')
    expect(result.status).to eq(405)
    expect(result['allow'].split(', ')).to match_array(%w[GET HEAD PATCH PUT DELETE])
    expect(request(app, 'POST', '/comments/1/delete').status).to eq(404)
  end

  it 'returns JSON for unknown paths, absent collections, and unmatched trailing segments' do
    app = build_app(namespace: space, routes: proc { resources :comments, only: [:show] })
    ['/unknown', '/comments', '/comments/1/extra', '/comments/'].each do |path|
      result = request(app, 'GET', path)
      expect(result.status).to eq(404)
      expect(result.content_type).to eq('application/json')
      expect(body(result)).to eq('error' => 'Not Found')
    end
  end

  it 'supports custom actions independently of their names and gives literal routes precedence' do
    publish = action(space, :comments, :publish) { |_r| {published: true} }
    search = action(space, :comments, :search) { |_r| {results: []} }
    app = build_app(namespace: space, routes: proc {
      resources :comments do
        member :publish, via: :post, controller: publish.first, handler: publish.last
        collection :search, via: :get, controller: search.first, handler: search.last
      end
    })
    expect(body(request(app, 'POST', '/comments/abc/publish'))).to eq('published' => true)
    expect(body(request(app, 'GET', '/comments/search'))).to eq('results' => [])
  end

  it 'supports shallow members while preserving version scopes' do
    app = build_app(namespace: space, routes: proc {
      scope '/v1' do
        resources(:projects) { resources :comments, shallow: true }
      end
    })
    expect(request(app, 'GET', '/v1/projects/1/comments').status).to eq(200)
    expect(body(request(app, 'GET', '/v1/comments/2'))['path']).to eq('id' => '2')
    expect(request(app, 'GET', '/v1/projects/1/comments/2').status).to eq(404)
    expect(request(app, 'GET', '/v1/comments').status).to eq(404)
  end

  it 'supports namespaced snake_case resources and explicit irregular identifier names' do
    admin = space.const_set(:Admin, Module.new)
    action(admin, :user_profiles, :show) { |r| {path: r.path_params} }
    action(admin, :people, :index) { |r| {path: r.path_params} }
    app = build_app(namespace: space, routes: proc {
      namespace :admin do
        resources :user_profiles, only: [:show], param: :slug, parent_key: :owner_slug do
          resources :people, only: [:index], singular: :person
        end
      end
    })
    expect(body(request(app, 'GET', '/admin/user_profiles/makevoid'))['path']).to eq('slug' => 'makevoid')
    expect(body(request(app, 'GET', '/admin/user_profiles/makevoid/people'))['path']).to eq('owner_slug' => 'makevoid')
  end

  it 'composes ordinary Roda routes and request authentication with generated routes' do
    hook = proc { |r| raise MK::Unauthorized unless r.env['HTTP_AUTHORIZATION'] == 'Bearer test-token' }
    custom = proc { |r| r.get('health') { {ok: true} } }
    app = build_app(namespace: space, routes: proc { resources :comments }, hook: hook, custom: custom)
    expect(request(app, 'GET', '/comments').status).to eq(401)
    expect(request(app, 'GET', '/health').status).to eq(401)
    expect(body(request(app, 'GET', '/health', 'HTTP_AUTHORIZATION' => 'Bearer test-token'))).to eq('ok' => true)
    expect(request(app, 'GET', '/comments', 'HTTP_AUTHORIZATION' => 'Bearer test-token').status).to eq(200)
  end

  it 'fails boot on duplicate routes and missing action implementations' do
    expect { build_app(namespace: space, routes: proc { resources :comments; resources :comments }) }.to raise_error(MK::ConfigurationError, /Duplicate route/)
    expect { build_app(namespace: space, routes: proc { resources :missing }) }.to raise_error(MK::ConfigurationError, /Missing action/)
  end

  it 'requires boot before serving requests and freezes configuration afterward' do
    expect { Class.new(MK::Application).app }.to raise_error(MK::ConfigurationError, /boot!/)
    app = build_app(namespace: space, routes: proc { resources :comments })
    expect(app).to be_frozen
    expect { app.configure(page_size: 10) }.to raise_error(MK::ConfigurationError)
  end

  it 'inherits authentication hooks and declarations from an unbooted application base' do
    base = Class.new(MK::Application)
    base.configure(root: __dir__, namespace: space, routes_path: 'missing_routes')
    base.resource_routes { resources :comments, only: [:index] }
    base.before_request { |r| raise MK::Unauthorized unless r.env['HTTP_AUTHORIZATION'] == 'Bearer allowed' }
    child = Class.new(base)
    child.configure(page_size: 10)
    child.boot!
    expect(request(child, 'GET', '/comments').status).to eq(401)
    expect(request(child, 'GET', '/comments', 'HTTP_AUTHORIZATION' => 'Bearer allowed').status).to eq(200)
    expect(base.settings[:page_size]).to eq(25)
  end

  it 'keeps two applications with identical controller names isolated under concurrent requests' do
    other = Module.new
    action(other, :comments, :index) { |_r| {app: 'other'} }
    first = build_app(namespace: space, routes: proc { resources :comments })
    second = build_app(namespace: other, routes: proc { resources :comments, only: [:index] })
    results = [first, second].map { |app| Thread.new { Array.new(20) { body(request(app, 'GET', '/comments')) } } }.map(&:value)
    expect(results.first.map { |item| item['action'] }.uniq).to eq(['index'])
    expect(results.last.uniq).to eq([{'app' => 'other'}])
  end
end
