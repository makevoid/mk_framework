# frozen_string_literal: true

require 'spec_helper'

describe "Todos" do
  describe "GET /todos" do
    before do
      Todo.dataset.delete

      @todo1 = Todo.create(
        title: "First Todo",
        description: "This is the first test todo",
        completed: false
      )

      @todo2 = Todo.create(
        title: "Second Todo",
        description: "This is the second test todo",
        completed: true
      )
    end

    it "returns all todos" do
      get '/todos'

      expect(last_response.status).to eq 200

      expect(resp.length).to eq 2

      expect(resp[0][:id]).to eq @todo1.id
      expect(resp[0][:title]).to eq "First Todo"
      expect(resp[0][:description]).to eq "This is the first test todo"
      expect(resp[0][:completed]).to eq false

      expect(resp[1][:id]).to eq @todo2.id
      expect(resp[1][:title]).to eq "Second Todo"
      expect(resp[1][:description]).to eq "This is the second test todo"
      expect(resp[1][:completed]).to eq true
    end
  end

  describe "POST /todos" do
    context "with valid parameters" do
      it "creates a new todo" do
        post '/todos', {
          title: "Test Todo",
          description: "This is a test todo"
        }

        expect(last_response.status).to eq 201

        expect(resp[:message]).to eq "Todo created"
        expect(resp[:todo][:title]).to eq "Test Todo"
        expect(resp[:todo][:description]).to eq "This is a test todo"
        expect(resp[:todo][:completed]).to eq false
      end
    end

    context "with invalid parameters" do
      it "returns validation errors when title is missing" do
        post '/todos', {
          description: "This todo has no title"
        }

        expect(last_response.status).to eq 422

        expect(resp[:error]).to eq "Validation failed"
        expect(resp[:details]).to have_key :title
      end

      it "returns validation errors when title is too long" do
        post '/todos', {
          title: "X" * 101,
          description: "This todo has a title that is too long"
        }

        expect(last_response.status).to eq 422

        expect(resp[:error]).to eq "Validation failed"
        expect(resp[:details]).to have_key :title
      end
    end
  end
end
