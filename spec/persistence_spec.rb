# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Explicit Sequel persistence' do
  let(:db) do
    database = Sequel.sqlite
    database.create_table(:records) { primary_key :id; String :name, null: false, unique: true }
    database
  end
  let(:model) do
    Class.new(Sequel::Model(db[:records])) do
      plugin :validation_helpers
      def validate
        super
        validates_presence :name
      end
    end
  end
  let(:writer) { Object.new.extend(MK::Persistence) }
  after { db.disconnect }

  it 'saves exactly once and never saves when a handler formats the result' do
    record = model.new(name: 'one')
    expect(record).to receive(:save).once.and_call_original
    writer.persist(record)
    handler = Class.new(MK::Handler)
    handler.handler { |_r| fields(model, :id, :name) }
    expect(handler.new(record).execute(nil)).to eq(id: record.id, name: 'one')
    expect(db[:records].count).to eq(1)
  end

  it 'runs destroy hooks exactly once' do
    record = model.create(name: 'one')
    expect(record).to receive(:before_destroy).once.and_call_original
    writer.destroy(record)
    expect(db[:records].count).to eq(0)
  end

  it 'maps model validation and unique constraint failures explicitly' do
    expect { writer.persist(model.new) }.to raise_error(MK::ValidationError) { |error| expect(error.details).to have_key(:name) }
    writer.persist(model.new(name: 'one'))
    expect { writer.persist(model.new(name: 'one')) }.to raise_error(MK::Conflict)
  end

  it 'rolls back a multi-record write when any child fails validation' do
    expect {
      db.transaction do
        writer.persist(model.new(name: 'parent'))
        writer.persist(model.new)
      end
    }.to raise_error(MK::ValidationError)
    expect(db[:records].count).to eq(0)
  end

  it 'does not swallow database failures that must reach the sanitized application handler' do
    record = model.new(name: 'one')
    allow(record).to receive(:save).and_raise(Sequel::DatabaseError, 'private detail')
    expect { writer.persist(record) }.to raise_error(Sequel::DatabaseError)
  end
end
