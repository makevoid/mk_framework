# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Kanban migrations' do
  let(:database) { Sequel.sqlite }
  let(:migrations) { File.join(SampleApp7::ROOT, 'db/migrations') }

  after { database.disconnect }

  it 'creates the complete schema and leaves existing data intact on repeated migration' do
    Sequel::Migrator.run(database, migrations)
    now = Time.now
    card_id = database[:cards].insert(title: 'Task', created_at: now, updated_at: now)
    comment_id = database[:comments].insert(card_id: card_id, content: 'Keep this', created_at: now, updated_at: now)
    expect(database[:cards][id: card_id]).to include(
      status: 'Todo', position: 0, priority: 'normal', archived: false,
      assignee: nil, due_date: nil
    )
    expect(database.indexes(:cards).values.map { |index| index[:columns] }).
      to contain_exactly([:archived, :status, :position], [:assignee], [:due_date])
    Sequel::Migrator.run(database, migrations)
    expect(database[:cards].count).to eq(1)
    expect(database[:comments][id: comment_id][:card_id]).to eq(card_id)
    expect(database[:comments][id: comment_id][:content]).to eq('Keep this')
  end

  it 'rolls back the entire schema and can migrate again' do
    Sequel::Migrator.run(database, migrations)
    Sequel::Migrator.run(database, migrations, target: 0)
    expect(database.table_exists?(:cards)).to be(false)
    expect(database.table_exists?(:comments)).to be(false)
    Sequel::Migrator.run(database, migrations)
    expect(database[:cards].columns).to include(:position, :priority, :assignee, :due_date, :archived)
    expect(database.table_exists?(:comments)).to be(true)
  end

  it 'enforces column, priority and position constraints in the database' do
    Sequel::Migrator.run(database, migrations)
    now = Time.now
    values = {title: 'Invalid', created_at: now, updated_at: now}
    [{status: 'Review'}, {priority: 'critical'}, {position: -1},
     {position: nil}, {archived: true},
     {status: 'Review', archived: true, position: nil},
     {priority: 'critical', archived: true, position: nil}].each do |invalid|
      expect { database[:cards].insert(values.merge(invalid)) }.
        to raise_error(Sequel::CheckConstraintViolation)
    end
    expect(database[:cards].count).to eq(0)
  end
end
