# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Scoped access across a deep API' do
  it 'requires the authenticated tenant and every URL parent to own the requested child' do
    db = Sequel.sqlite
    db.create_table(:organizations) { primary_key :id; Integer :tenant_id }
    db.create_table(:projects) { primary_key :id; foreign_key :organization_id, :organizations }
    db.create_table(:comments) { primary_key :id; foreign_key :project_id, :projects; String :content }
    org1 = db[:organizations].insert(tenant_id: 1)
    org2 = db[:organizations].insert(tenant_id: 2)
    project1 = db[:projects].insert(organization_id: org1)
    project2 = db[:projects].insert(organization_id: org2)
    comment = db[:comments].insert(project_id: project1, content: 'private')
    space = Module.new
    action(space, :comments, :show) do |r|
      # Tenant identity comes from authentication, never the body or query string.
      organization = db[:organizations].where(tenant_id: r.env.fetch('current_tenant'), id: r.path_params.fetch(:organization_id)).first or raise MK::NotFound
      project = db[:projects].where(organization_id: organization.fetch(:id), id: r.path_params.fetch(:project_id)).first or raise MK::NotFound
      db[:comments].where(project_id: project.fetch(:id), id: r.path_params.fetch(:id)).first
    end
    hook = proc do |r|
      # A deterministic authentication stub for this integration test.
      tenant = {'Bearer tenant-one' => 1, 'Bearer tenant-two' => 2}[r.env['HTTP_AUTHORIZATION']]
      raise MK::Unauthorized unless tenant
      r.env['current_tenant'] = tenant
    end
    app = build_app(namespace: space, hook: hook, routes: proc {
      resources :organizations, only: [] do
        resources :projects, only: [] do
          resources :comments, only: [:show]
        end
      end
    })
    path = "/organizations/#{org1}/projects/#{project1}/comments/#{comment}"
    expect(request(app, 'GET', path).status).to eq(401)
    expect(request(app, 'GET', path, 'HTTP_AUTHORIZATION' => 'Bearer tenant-two').status).to eq(404)
    expect(request(app, 'GET', path + '?tenant_id=2', 'HTTP_AUTHORIZATION' => 'Bearer tenant-one').status).to eq(200)
    wrong_parent = "/organizations/#{org2}/projects/#{project2}/comments/#{comment}"
    expect(request(app, 'GET', wrong_parent, 'HTTP_AUTHORIZATION' => 'Bearer tenant-two').status).to eq(404)
    crossed = "/organizations/#{org1}/projects/#{project2}/comments/#{comment}"
    expect(request(app, 'GET', crossed, 'HTTP_AUTHORIZATION' => 'Bearer tenant-one').status).to eq(404)
  ensure
    db&.disconnect
  end
end
