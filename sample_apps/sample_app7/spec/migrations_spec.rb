# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Kanban migrations' do
  let(:database) { Sequel.sqlite }
  let(:migrations) { File.join(SampleApp7::ROOT, 'db/migrations') }

  after { database.disconnect }

  it 'upgrades existing cards with per-column positions while retaining comments' do
    Sequel::Migrator.run(database, migrations, target: 1)
    now = Time.now
    ids = ['Todo', 'Done', 'Todo'].map do |status|
      database[:cards].insert(title: status, status: status, created_at: now, updated_at: now)
    end
    comment_id = database[:comments].insert(card_id: ids.first, content: 'Keep this', created_at: now, updated_at: now)
    Sequel::Migrator.run(database, migrations)
    expect(database[:cards].order(:id).select_map(:position)).to eq([0, 0, 1])
    expect(database[:cards].select_map(:priority)).to eq(%w[normal normal normal])
    expect(database[:cards].select_map(:archived)).to eq([false, false, false])
    expect(database[:comments][id: comment_id][:card_id]).to eq(ids.first)
    Sequel::Migrator.run(database, migrations)
    expect(database[:cards].count).to eq(3)
    Sequel::Migrator.run(database, migrations, target: 1)
    expect(database[:cards].columns).not_to include(:position)
    expect(database[:comments][id: comment_id][:content]).to eq('Keep this')
    Sequel::Migrator.run(database, migrations)
    expect(database[:cards].order(:id).select_map(:position)).to eq([0, 0, 1])
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
