# frozen_string_literal: true

require_relative '../spec_helper'

module SampleApp7
  RSpec.describe 'Three-column Kanban board' do
    before do
      Comment.dataset.delete
      Card.dataset.delete
    end

    def json_request(method, path, attributes)
      public_send(method, path, JSON.generate(attributes), 'CONTENT_TYPE' => 'application/json')
    end

    def create_card(title, **attributes)
      json_request(:post, '/cards', {title: title, **attributes})
      expect(last_response.status).to eq(201), last_response.body
      resp.fetch(:card)
    end

    def expect_lane(status, *ids)
      cards = Card.where(status: status, archived: false).order(:position).all
      expect(cards.map(&:id)).to eq(ids)
      expect(cards.map(&:position)).to eq((0...ids.length).to_a)
    end

    it 'always returns the three fixed columns, including empty columns' do
      get '/board'
      expect(last_response.status).to eq(200)
      expect(resp).to include(total: 0, limit: 25, offset: 0)
      expect(resp[:columns]).to eq(Card::STATUSES.map { |status| {status: status, total: 0, cards: []} })
      head '/board'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('')
      post '/board', status: 'Review'
      expect(last_response.status).to eq(405)
    end

    it 'creates defaults and appends cards to their column' do
      first = create_card('First')
      second = create_card('Second')
      expect(first).to include(status: 'Todo', priority: 'normal', archived: false,
                               position: 0, assignee: nil, due_date: nil)
      expect(first[:created_at]).not_to be_nil
      expect(first[:updated_at]).not_to be_nil
      expect_lane('Todo', first[:id], second[:id])
    end

    it 'inserts at a requested position without reordering other columns' do
      first = create_card('First')
      second = create_card('Second')
      other = create_card('Other', status: 'Done')
      inserted = create_card('Inserted', position: 1)
      expect_lane('Todo', first[:id], inserted[:id], second[:id])
      expect_lane('Done', other[:id])
    end

    it 'moves in both directions within a column and handles no-op moves' do
      first, second, third = %w[First Second Third].map { |title| create_card(title) }
      json_request(:patch, "/cards/#{first[:id]}/move", position: 2)
      expect(last_response.status).to eq(200)
      expect(resp[:message]).to eq('Card moved')
      expect_lane('Todo', second[:id], third[:id], first[:id])
      json_request(:patch, "/cards/#{first[:id]}/move", position: 0)
      expect(last_response.status).to eq(200)
      expect_lane('Todo', first[:id], second[:id], third[:id])
      json_request(:patch, "/cards/#{second[:id]}/move", position: 1)
      expect(last_response.status).to eq(200)
      expect_lane('Todo', first[:id], second[:id], third[:id])
    end

    it 'moves across columns, compacts the source, and inserts in the destination' do
      first = create_card('First')
      second = create_card('Second')
      other = create_card('Other', status: 'In Progress')
      json_request(:patch, "/cards/#{first[:id]}/move", status: 'In Progress', position: 0)
      expect(last_response.status).to eq(200)
      expect_lane('Todo', second[:id])
      expect_lane('In Progress', first[:id], other[:id])
      json_request(:patch, "/cards/#{second[:id]}", status: 'In Progress')
      expect(last_response.status).to eq(200)
      expect_lane('Todo')
      expect_lane('In Progress', first[:id], other[:id], second[:id])
      json_request(:patch, "/cards/#{first[:id]}/move", status: 'Done')
      expect(last_response.status).to eq(200)
      expect_lane('Done', first[:id])
      json_request(:patch, "/cards/#{first[:id]}/move", status: 'Todo')
      expect(last_response.status).to eq(200)
      expect_lane('Todo', first[:id])
    end

    it 'supports ordering through PUT and legacy POST updates' do
      first, second = %w[First Second].map { |title| create_card(title) }
      json_request(:put, "/cards/#{second[:id]}", position: 0, title: 'Updated')
      expect(last_response.status).to eq(200)
      expect(resp[:card][:title]).to eq('Updated')
      expect_lane('Todo', second[:id], first[:id])
      post "/cards/#{second[:id]}", position: '1'
      expect(last_response.status).to eq(200)
      expect_lane('Todo', first[:id], second[:id])
    end

    it 'rolls back every position and attribute on failed validation' do
      first = create_card('First')
      create_card('Second')
      create_card('Other', status: 'Done')
      before = Card.order(:id).all.map(&:values)
      json_request(:patch, "/cards/#{first[:id]}", status: 'Done', position: 0, title: '')
      expect(last_response.status).to eq(422)
      expect(Card.order(:id).all.map(&:values)).to eq(before)
      json_request(:post, '/cards', position: 0, title: '')
      expect(last_response.status).to eq(422)
      expect(Card.order(:id).all.map(&:values)).to eq(before)
    end

    it 'rejects an out-of-bounds position without changing the board' do
      first = create_card('First')
      json_request(:patch, "/cards/#{first[:id]}/move", position: 1)
      expect(last_response.status).to eq(422)
      expect(resp[:details]).to have_key(:position)
      json_request(:post, '/cards', title: 'Invalid', status: 'Done', position: 1)
      expect(last_response.status).to eq(422)
      expect_lane('Todo', first[:id])
      expect_lane('Done')
    end

    [-1, '1.2', 1.5, nil, true, [], {}].each do |position|
      it "rejects malformed position #{position.inspect}" do
        first = create_card('First')
        json_request(:patch, "/cards/#{first[:id]}/move", position: position)
        expect(last_response.status).to eq(400)
        expect_lane('Todo', first[:id])
      end
    end

    it 'rejects empty moves, unknown columns, and missing cards' do
      first = create_card('First')
      json_request(:patch, "/cards/#{first[:id]}/move", title: 'Ignored')
      expect(last_response.status).to eq(400)
      json_request(:patch, "/cards/#{first[:id]}/move", status: 'Review')
      expect(last_response.status).to eq(422)
      json_request(:patch, '/cards/999999/move', position: 0)
      expect(last_response.status).to eq(404)
      expect_lane('Todo', first[:id])
    end

    it 'archives, lists the archive, and restores at a requested position with comments intact' do
      first, second = %w[First Second].map { |title| create_card(title) }
      comment = Comment.create(card_id: first[:id], content: 'Keep me')
      json_request(:patch, "/cards/#{first[:id]}", archived: true)
      expect(last_response.status).to eq(200)
      expect(resp[:card]).to include(archived: true, position: nil)
      expect_lane('Todo', second[:id])
      get '/cards'
      expect(resp.map { |card| card[:id] }).to eq([second[:id]])
      get '/cards', archived: 'true'
      expect(resp.map { |card| card[:id] }).to eq([first[:id]])
      get '/board'
      expect(resp[:total]).to eq(1)
      get "/cards/#{first[:id]}"
      expect(resp[:comments].map { |item| item[:id] }).to eq([comment.id])
      json_request(:patch, "/cards/#{first[:id]}/move", status: 'Done')
      expect(last_response.status).to eq(409)
      json_request(:patch, "/cards/#{first[:id]}", archived: false, position: 0)
      expect(last_response.status).to eq(200)
      expect_lane('Todo', first[:id], second[:id])
    end

    it 'appends restored cards and can create archived cards without a position' do
      archived = create_card('Archived', archived: true)
      active = create_card('Active')
      expect(archived[:position]).to be_nil
      json_request(:patch, "/cards/#{archived[:id]}", archived: false)
      expect(last_response.status).to eq(200)
      expect_lane('Todo', active[:id], archived[:id])
      json_request(:patch, "/cards/#{active[:id]}", archived: true, position: 0)
      expect(last_response.status).to eq(400)
      expect_lane('Todo', active[:id], archived[:id])
    end

    it 'deletes with cascading comments and compacts positions once' do
      first, second, third = %w[First Second Third].map { |title| create_card(title) }
      comment = Comment.create(card_id: second[:id], content: 'Delete me')
      expect_any_instance_of(Card).to receive(:before_destroy).once.and_call_original
      delete "/cards/#{second[:id]}"
      expect(last_response.status).to eq(200)
      expect(Comment[comment.id]).to be_nil
      expect_lane('Todo', first[:id], third[:id])
    end

    it 'deletes archived cards without shifting active positions' do
      active = create_card('Active')
      archived = create_card('Archived', archived: true)
      delete "/cards/#{archived[:id]}"
      expect(last_response.status).to eq(200)
      expect_lane('Todo', active[:id])
    end

    it 'saves each create and update exactly once, and updates timestamps' do
      calls = 0
      allow_any_instance_of(Card).to receive(:save).and_wrap_original do |original, *args|
        calls += 1
        original.call(*args)
      end
      first = create_card('First')
      expect(calls).to eq(1)
      old = Time.now - 3600
      Card.where(id: first[:id]).update(updated_at: old)
      json_request(:patch, "/cards/#{first[:id]}", title: 'Updated')
      expect(last_response.status).to eq(200)
      expect(calls).to eq(2)
      expect(Card[first[:id]].updated_at).to be > old
    end

    it 'stores priority, assignee and a due date and clears nullable fields' do
      card = create_card('Release', description: 'Ship it', priority: 'urgent',
                         assignee: 'Alice', due_date: '2026-09-30')
      expect(card).to include(priority: 'urgent', assignee: 'Alice', due_date: '2026-09-30')
      json_request(:patch, "/cards/#{card[:id]}", description: nil, assignee: nil, due_date: nil)
      expect(last_response.status).to eq(200)
      expect(resp[:card]).to include(description: nil, assignee: nil, due_date: nil, priority: 'urgent')
    end

    [{priority: 'critical'}, {due_date: '2026-02-30'}, {due_date: '20260930'},
     {due_date: ''}, {assignee: 'x' * 101}, {description: 'x' * 10_001}].each do |attributes|
      it "rejects invalid #{attributes.keys.first} values" do
        json_request(:post, '/cards', {title: 'Invalid', **attributes})
        expect(last_response.status).to eq(422)
        expect(Card.count).to eq(0)
      end
    end

    it 'ignores client IDs and timestamps and rejects malformed JSON objects' do
      card = create_card('Safe', id: 999999, created_at: '2000-01-01', updated_at: '2000-01-01')
      expect(card[:id]).not_to eq(999999)
      expect(Card[card[:id]].created_at.year).to eq(Time.now.year)
      ['[]', '{', 'null'].each do |body|
        post '/cards', body, 'CONTENT_TYPE' => 'application/json'
        expect(last_response.status).to eq(400)
      end
      expect(Card.count).to eq(1)
    end

    it 'paginates each column independently and includes full filtered counts' do
      cards = Card::STATUSES.to_h do |status|
        [status, 3.times.map { |index| create_card("#{status} #{index}", status: status) }]
      end
      get '/board', limit: 1, offset: 1
      expect(last_response.status).to eq(200)
      expect(resp).to include(total: 9, limit: 1, offset: 1)
      resp[:columns].each do |column|
        expect(column[:total]).to eq(3)
        expect(column[:cards].map { |card| card[:id] }).to eq([cards[column[:status]][1][:id]])
      end
      get '/cards', status: 'In Progress', limit: 1, offset: 2
      expect(resp.map { |card| card[:id] }).to eq([cards['In Progress'][2][:id]])
      get '/board', offset: 100
      expect(resp[:total]).to eq(9)
      expect(resp[:columns].flat_map { |column| column[:cards] }).to be_empty
    end

    it 'filters and searches the board and cards using literal case-insensitive text' do
      target = create_card('Fix LOGIN 100%_bug', description: 'Authentication',
                            status: 'In Progress', priority: 'high', assignee: 'Alice')
      create_card('Fix login 100XXbug', priority: 'low', assignee: 'Bob')
      get '/cards', q: 'login', priority: 'high', assignee: 'Alice', status: 'In Progress'
      expect(last_response.status).to eq(200)
      expect(resp.map { |card| card[:id] }).to eq([target[:id]])
      get '/cards', q: '100%_'
      expect(resp.map { |card| card[:id] }).to eq([target[:id]])
      get '/board', q: 'AUTHENTICATION'
      expect(resp[:total]).to eq(1)
      expect(resp[:columns].map { |column| column[:total] }).to eq([0, 1, 0])
    end

    it 'filters overdue cards, excluding Done and cards due today' do
      overdue = create_card('Late', due_date: (Date.today - 1).iso8601)
      done = create_card('Finished', due_date: (Date.today - 1).iso8601, status: 'Done')
      today = create_card('Today', due_date: Date.today.iso8601)
      undated = create_card('Undated')
      get '/cards', overdue: 'true'
      expect(resp.map { |card| card[:id] }).to eq([overdue[:id]])
      get '/cards', overdue: 'false'
      expect(resp.map { |card| card[:id] }).to contain_exactly(done[:id], today[:id], undated[:id])
    end

    [{status: 'Review'}, {priority: 'bad'}, {archived: 'maybe'}, {overdue: 'maybe'},
     {limit: 0}, {limit: 101}, {offset: -1}, {offset: 10_001}, {q: 'x' * 201}].each do |query|
      it "rejects invalid query #{query.keys.first}=#{query.values.first.to_s[0, 20]}" do
        ['/cards', '/board'].each do |path|
          get path, query
          expect(last_response.status).to eq(400)
        end
      end
    end

    it 'directs archive browsing to the cards endpoint' do
      get '/board', archived: 'true'
      expect(last_response.status).to eq(400)
    end
  end
end
