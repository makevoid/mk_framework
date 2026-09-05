# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Automatic Sequel action lifecycle' do
  let(:db) do
    Sequel.sqlite.tap do |database|
      database.create_table(:records) { primary_key :id; String :name, null: false, unique: true }
    end
  end
  let(:record_class) do
    Class.new(Sequel::Model(db[:records])) do
      plugin :validation_helpers
      def validate
        super
        validates_presence :name
      end
    end
  end
  after { db.disconnect }

  def lifecycle_app(action_name, &block)
    namespace = Module.new
    action(namespace, :records, action_name, &block)
    build_app(namespace: namespace, routes: proc { resources :records, only: [action_name] })
  end

  it 'saves a create result once and gives the handler persisted raw attributes' do
    record = record_class.new(name: 'created')
    expect(record).to receive(:save).once.and_call_original
    app = lifecycle_app(:create) { |_r| record }

    response = request(app, 'POST', '/records')

    expect(response.status).to eq(200)
    expect(body(response)).to eq('id' => record.id, 'name' => 'created')
    expect(record_class.count).to eq(1)
  end

  %w[PATCH PUT POST].each do |verb|
    it "saves an update once via #{verb}" do
      record = record_class.create(name: 'original')
      expect(record).to receive(:save).once.and_call_original
      app = lifecycle_app(:update) { |_r| record.set(name: 'updated') }

      response = request(app, verb, "/records/#{record.id}")

      expect(response.status).to eq(200)
      expect(body(response)).to eq('id' => record.id, 'name' => 'updated')
      expect(record.refresh.name).to eq('updated')
    end
  end

  [['DELETE', ''], ['POST', '/delete']].each do |verb, suffix|
    it "destroys a delete result once with hooks via #{verb}" do
      record = record_class.create(name: 'deleted')
      expect(record).to receive(:destroy).once.and_call_original
      expect(record).to receive(:before_destroy).once.and_call_original
      app = lifecycle_app(:delete) { |_r| record }

      response = request(app, verb, "/records/#{record.id}#{suffix}")

      expect(response.status).to eq(200)
      expect(body(response)).to eq('id' => record.id, 'name' => 'deleted')
      expect(record_class[record.id]).to be_nil
    end
  end

  it 'converts show results to attributes without saving or destroying' do
    record = record_class.create(name: 'original')
    expect(record).not_to receive(:save)
    expect(record).not_to receive(:destroy)
    app = lifecycle_app(:show) { |_r| record }

    expect(body(request(app, 'GET', "/records/#{record.id}"))).to eq('id' => record.id, 'name' => 'original')
  end

  it 'materializes datasets and nested records before executing the handler' do
    record = record_class.create(name: 'original')
    dataset = record_class.where(id: record.id)
    namespace = Module.new
    _, handler = action(namespace, :records, :index) { |_r| {record: record, records: dataset, list: [record]} }
    handler.handler do |_r|
      raise 'Model reached handler' unless model[:record].is_a?(Hash)
      raise 'Dataset reached handler' unless model[:records].is_a?(Array) && model[:records].first.is_a?(Hash)
      model
    end
    app = build_app(namespace: namespace, routes: proc { resources :records, only: [:index] })

    attributes = {'id' => record.id, 'name' => 'original'}
    expect(body(request(app, 'GET', '/records'))).to eq('record' => attributes, 'records' => [attributes], 'list' => [attributes])
  end

  it 'uses the registered action even when explicitly mapped to a differently named controller' do
    record = record_class.new(name: 'created')
    namespace = Module.new
    pair = action(namespace, :records, :show) { |_r| record }
    app = build_app(namespace: namespace, routes: proc { resources :records, only: [:create], actions: {create: pair} })

    expect(request(app, 'POST', '/records').status).to eq(200)
    expect(record_class.count).to eq(1)
  end

  it 'does not save records returned by custom actions' do
    record = record_class.new(name: 'preview')
    namespace = Module.new
    controller, handler = action(namespace, :records, :create) { |_r| record }
    app = build_app(namespace: namespace, routes: proc {
      resources :records, only: [] do
        collection :preview, via: :post, controller: controller, handler: handler
      end
    })

    expect(body(request(app, 'POST', '/records/preview'))).to eq('name' => 'preview')
    expect(record_class.count).to eq(0)
  end

  it 'leaves plain hashes and arrays usable for service-backed actions' do
    app = lifecycle_app(:create) { |_r| {items: [{name: 'service result'}]} }
    expect(body(request(app, 'POST', '/records'))).to eq('items' => [{'name' => 'service result'}])
  end

  it 'returns 422 without running the handler when validation fails' do
    record = record_class.new
    namespace = Module.new
    _, handler = action(namespace, :records, :create) { |_r| record }
    expect(handler).not_to receive(:new)
    app = build_app(namespace: namespace, routes: proc { resources :records, only: [:create] })

    response = request(app, 'POST', '/records')
    expect(response.status).to eq(422)
    expect(body(response)['details']).to have_key('name')
    expect(record_class.count).to eq(0)
  end

  it 'also returns 422 when a model is configured to return nil on validation failure' do
    record = record_class.new
    record.raise_on_save_failure = false
    app = lifecycle_app(:create) { |_r| record }
    expect(request(app, 'POST', '/records').status).to eq(422)
    expect(record_class.count).to eq(0)
  end

  it 'returns 409 for a unique constraint conflict' do
    record_class.create(name: 'duplicate')
    record = record_class.new(name: 'duplicate')
    app = lifecycle_app(:create) { |_r| record }
    expect(request(app, 'POST', '/records').status).to eq(409)
    expect(record_class.count).to eq(1)
  end

  it 'returns 404 for a missing member before running the lifecycle' do
    app = lifecycle_app(:delete) { |_r| nil }
    expect(request(app, 'DELETE', '/records/999').status).to eq(404)
  end
end
