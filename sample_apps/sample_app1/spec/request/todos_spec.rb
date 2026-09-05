# frozen_string_literal: true

require_relative '../spec_helper'

module SampleApp1
  RSpec.describe 'Todos CRUD' do
    before { Todo.dataset.delete }

    it 'creates, lists, shows, updates, and deletes a todo' do
      post '/todos', JSON.generate(title: 'First', completed: true), 'CONTENT_TYPE' => 'application/json'
      expect(last_response.status).to eq(201)
      id = resp[:todo][:id]
      get '/todos'
      expect(resp.first[:id]).to eq(id)
      get "/todos/#{id}"
      expect(resp[:completed]).to eq(true)
      patch "/todos/#{id}", JSON.generate(completed: false), 'CONTENT_TYPE' => 'application/json'
      expect(last_response.status).to eq(200)
      expect(Todo[id].completed).to eq(false)
      delete "/todos/#{id}"
      expect(last_response.status).to eq(200)
      expect(Todo[id]).to be_nil
    end

    it 'rejects invalid input and permits only declared fields' do
      post '/todos', description: 'Missing title'
      expect(last_response.status).to eq(422)
      post '/todos', title: 'Safe', id: 9999, created_at: '1900-01-01'
      expect(last_response.status).to eq(201)
      expect(resp[:todo][:id]).not_to eq(9999)
      get '/todos', limit: 101
      expect(last_response.status).to eq(400)
    end
  end
end
