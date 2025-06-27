## Testing

MK Framework includes test helpers for RSpec and Rack::Test. Here's how to set up and write tests for your Todo app:

```ruby
# spec/spec_helper.rb
require 'rspec'
require 'rack/test'
require 'json'
require_relative '../app'
require_relative '../../lib_spec/mk_framework_spec_helpers'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  
  def app
    TodoApp.app
  end
  
  config.include MK::Framework::Spec
end
```

### Example Test Cases

#### 1. Show Todo Test

```ruby
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
```

#### 2. Create Todo Test

```ruby
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
```

#### 3. Update Todo Test

```ruby
describe "POST /todos/:id" do
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

    it "updates the todo completed status" do
      post "/todos/#{@todo.id}", {
        completed: true
      }

      expect(last_response.status).to eq 200

      expect(resp[:message]).to eq "Todo updated"
      expect(resp[:todo][:id]).to eq @todo.id
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
```
