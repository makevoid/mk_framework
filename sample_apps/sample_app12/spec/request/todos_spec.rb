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
      expect(resp[:custom_field]).to eq "Custom value for index"

      todos = resp[:todos]
      expect(todos.length).to eq 2
      expect(todos[0][:id]).to eq @todo1.id
      expect(todos[0][:title]).to eq "First Todo"
      expect(todos[0][:description]).to eq "This is the first test todo"
      expect(todos[0][:completed]).to eq false

      expect(todos[1][:id]).to eq @todo2.id
      expect(todos[1][:title]).to eq "Second Todo"
      expect(todos[1][:description]).to eq "This is the second test todo"
      expect(todos[1][:completed]).to eq true
    end
  end

  describe "GET /todos/:id" do
    before do
      Todo.dataset.delete

      @todo = Todo.create(
        title: "Test Todo",
      )
    end

    context "when todo exists" do
      it "returns the todo" do
        get "/todos/#{@todo.id}"

        expect(last_response.status).to eq 200

        expect(resp[:id]).to eq @todo.id
        expect(resp[:title]).to eq "Test Todo"
      end
    end

    context "when todo does not exist" do
      it "returns a 404 error" do
        get "/todos/999999"

        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "Todo not found"
      end
    end
  end

  describe "POST /todos" do
    context "with valid parameters" do
      it "creates a new todo" do
        post '/todos', {
          title: "Test Todo",
        }

        expect(last_response.status).to eq 201

        expect(resp[:message]).to eq "Todo created"
        expect(resp[:todo][:title]).to eq "Test Todo"
      end
    end
  end

  describe "PUT /todos/:id" do
    before do
      Todo.dataset.delete

      @todo = Todo.create(
        title: "Original Title",
      )
    end

    context "when todo exists" do
      it "updates the todo title" do
        post "/todos/#{@todo.id}", {
          title: "Updated Title"
        }

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Todo updated"
        expect(resp[:todo][:id]).to eq @todo.id
        expect(resp[:todo][:title]).to eq "Updated Title"
      end

      it "updates the todo completed status" do
        post "/todos/#{@todo.id}", {
          completed: true
        }

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Todo updated"
        expect(resp[:todo][:id]).to eq @todo.id
        expect(resp[:todo][:title]).to eq "Original Title"
      end

      it "updates multiple fields at once" do
        post "/todos/#{@todo.id}", {
          title: "Completely Updated",
        }

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Todo updated"
        expect(resp[:todo][:id]).to eq @todo.id
        expect(resp[:todo][:title]).to eq "Completely Updated"
      end
    end

    context "when todo does not exist" do
      it "returns a 404 error" do
        post "/todos/999999", {
          title: "Updated Title"
        }

        expect(last_response.status).to eq 404
        expect(resp[:message]).to eq "todo not found"
      end
    end
  end

  describe "DELETE /todos/:id" do
    before do
      Todo.dataset.delete

      @todo = Todo.create(
        title: "Todo to Delete",
      )
    end

    context "when todo exists" do
      it "deletes the todo" do
        post "/todos/#{@todo.id}/delete"

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Todo deleted successfully"
        expect(resp[:todo][:id]).to eq @todo.id
        expect(resp[:todo][:title]).to eq "Todo to Delete"

        # Verify that the todo was actually deleted from the database
        expect(Todo[@todo.id]).to be_nil
      end
    end

    context "when todo does not exist" do
      it "returns a 404 error" do
        delete "/todos/999999"

        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "Todo not found"
      end
    end
  end
end
