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

  describe "GET /todos/:id" do
    before do
      Todo.dataset.delete

      @todo = Todo.create(
        title: "Test Todo",
        description: "This is a test todo",
        completed: false
      )
    end

    context "when todo exists" do
      it "returns the todo" do
        get "/todos/#{@todo.id}"

        expect(last_response.status).to eq 200

        expect(resp[:id]).to eq @todo.id
        expect(resp[:title]).to eq "Test Todo"
        expect(resp[:description]).to eq "This is a test todo"
        expect(resp[:completed]).to eq false
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

  describe "PUT /todos/:id" do
    before do
      Todo.dataset.delete

      @todo = Todo.create(
        title: "Original Title",
        description: "Original Description",
        completed: false
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
        expect(resp[:todo][:description]).to eq "Original Description"
        expect(resp[:todo][:completed]).to eq false
      end

      it "updates the todo description" do
        post "/todos/#{@todo.id}", {
          description: "Updated Description"
        }

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Todo updated"
        expect(resp[:todo][:id]).to eq @todo.id
        expect(resp[:todo][:title]).to eq "Original Title"
        expect(resp[:todo][:description]).to eq "Updated Description"
        expect(resp[:todo][:completed]).to eq false
      end

      it "updates the todo completed status" do
        post "/todos/#{@todo.id}", {
          completed: true
        }

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Todo updated"
        expect(resp[:todo][:id]).to eq @todo.id
        expect(resp[:todo][:title]).to eq "Original Title"
        expect(resp[:todo][:description]).to eq "Original Description"
        expect(resp[:todo][:completed]).to eq true
      end

      it "updates multiple fields at once" do
        post "/todos/#{@todo.id}", {
          title: "Completely Updated",
          description: "New Description",
          completed: true
        }

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Todo updated"
        expect(resp[:todo][:id]).to eq @todo.id
        expect(resp[:todo][:title]).to eq "Completely Updated"
        expect(resp[:todo][:description]).to eq "New Description"
        expect(resp[:todo][:completed]).to eq true
      end

      it "returns validation errors when title is too long" do
        post "/todos/#{@todo.id}", {
          title: "X" * 101
        }

        expect(last_response.status).to eq 400

        expect(resp[:error]).to eq "Validation failed!"
        expect(resp[:details]).to have_key :title
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
        description: "This todo will be deleted",
        completed: false
      )
    end

    context "when todo exists" do
      it "deletes the todo" do
        post "/todos/#{@todo.id}/delete"

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Todo deleted successfully"
        expect(resp[:todo][:id]).to eq @todo.id
        expect(resp[:todo][:title]).to eq "Todo to Delete"
        expect(resp[:todo][:description]).to eq "This todo will be deleted"
        expect(resp[:todo][:completed]).to eq false

        # Verify that the todo was actually deleted from the database
        expect(Todo[@todo.id]).to be_nil
      end
    end

    context "when todo does not exist" do
      it "returns a 404 error" do
        delete "/todos/999999"

        expect(last_response.status).to eq 404
        expect(resp).to be_empty
      end
    end
  end
end
