# MK Framework

MK Framework is a lightweight, Ruby-based API framework inspired by Ruby on Rails' MVC pattern. It implements an MVC architecture for API development, where JSON responses serve as the "view" layer.

## Features

- Built on top of [Roda](https://github.com/jeremyevans/roda) for routing
- [Sequel](https://github.com/jeremyevans/sequel) for database interactions
- Conventional RESTful route structure
- Clear separation of concerns with Controllers and Handlers
- Automatic route generation based on directory structure
- Database-agnostic (works with SQLite, PostgreSQL, MySQL, etc.)
- Built-in error handling and JSON formatting
- CORS support for API requests
- Nested resource support
- RSpec and Rack::Test for testing

## Philosophy

MK Framework follows a unique Controller-Handler separation pattern, where:

- **Controllers**: Handle data retrieval and business logic BEFORE saving data
- **Handlers**: Format responses and set HTTP statuses AFTER controller execution

This separation allows for:
1. Clean, focused business logic in controllers
2. Consistent response formatting in handlers
3. Easy success/error handling through handler blocks

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mk_framework', path: '/path/to/mk_framework'
```

Or install it directly:

```bash
gem build mk_framework.gemspec
gem install mk_framework-0.1.0.gem
```

## Getting Started

### Create a New Application

1. Create your application structure:

```
todo_app/
├── app.rb
├── config.ru
├── models/
│   └── todo.rb
└── routes/
    └── todos/
        ├── controllers/
        │   ├── create.rb
        │   ├── delete.rb
        │   ├── index.rb
        │   ├── show.rb
        │   └── update.rb
        └── handlers/
            ├── create.rb
            ├── delete.rb
            ├── index.rb
            ├── show.rb
            └── update.rb
```

2. Set up your application:

```ruby
# app.rb
require 'sequel'
require 'json'
require 'roda'
require_relative '../lib/mk_framework'

# Set up database connection
DB = Sequel.connect('sqlite://todos.db')

# Create todos table if it doesn't exist
DB.create_table? :todos do
  primary_key :id
  String :title, null: false
  String :description
  TrueClass :completed, default: false
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
end

# Require models
require_relative 'models/todo'

# Create application instance
class TodoApp < MK::Application
  # No need to override initialize - the parent class handles everything
end
```

3. Set up your Rack configuration:

```ruby
# config.ru
require_relative 'app'

# Run the TodoApp class directly as a Rack app
run TodoApp
```

### Define Your Models

```ruby
# models/todo.rb
class Todo < Sequel::Model
  plugin :validation_helpers

  def validate
    super
    validates_presence [:title]
    validates_max_length 100, :title
  end
end
```

### Define Controllers and Handlers

#### Index (List all resources)

```ruby
# routes/todos/controllers/index.rb
class TodosIndexController < MK::Controller
  route do |r|
    Todo.all
  end
end
```

```ruby
# routes/todos/handlers/index.rb
class TodosIndexHandler < MK::Handler
  handler do |r|
    model.map(&:to_hash)
  end
end
```

#### Show (Get a single resource)

```ruby
# routes/todos/controllers/show.rb
class TodosShowController < MK::Controller
  route do |r|
    Todo[r.params.fetch('id')]
  end
end
```

```ruby
# routes/todos/handlers/show.rb
class TodosShowHandler < MK::Handler
  handler do |r|
    model.to_hash
  end
end
```

#### Create

```ruby
# routes/todos/controllers/create.rb
class TodosCreateController < MK::Controller
  route do |r|
    Todo.new(
      title: r.params['title'],
      description: r.params['description'],
      completed: r.params['completed'] || false
    )
  end
end
```

```ruby
# routes/todos/handlers/create.rb
class TodosCreateHandler < MK::Handler
  handler do |r|
    success do |r|
      r.response.status = 201
      {
        message: "Todo created",
        todo: model.to_hash
      }
    end

    error do |r|
      r.response.status = 422
      {
        error: "Validation failed",
        details: model.errors
      }
    end
  end
end
```

#### Update

```ruby
# routes/todos/controllers/update.rb
class TodosUpdateController < MK::Controller
  route do |r|
    todo = Todo[r.params.fetch('id')]
    
    r.halt(404, { message: "todo not found" }) if todo.nil?

    todo.title = r.params['title'] if r.params.key?('title')
    todo.description = r.params['description'] if r.params.key?('description')
    todo.completed = r.params['completed'] if r.params.key?('completed')
    
    todo
  end
end
```

```ruby
# routes/todos/handlers/update.rb
class TodosUpdateHandler < MK::Handler
  handler do |r|
    success do |r|
      {
        message: "Todo updated",
        todo: model.to_hash
      }
    end

    error do |r|
      r.response.status = 400
      {
        error: "Validation failed!",
        details: model.errors
      }
    end
  end
end
```

#### Delete

```ruby
# routes/todos/controllers/delete.rb
class TodosDeleteController < MK::Controller
  route do |r|
    todo = Todo[r.params.fetch('id')]
    
    r.halt(404, { message: "todo not found" }) if todo.nil?
    
    todo
  end
end
```

```ruby
# routes/todos/handlers/delete.rb
class TodosDeleteHandler < MK::Handler
  handler do |r|
    success do |r|
      {
        message: "Todo deleted successfully",
        todo: model.to_hash
      }
    end

    error do |r|
      r.response.status = 500
      {
        error: "Failed to delete todo"
      }
    end
  end
end
```

### Run Your Application

```bash
bundle exec rackup -p 9292
```

## RESTful API Routes

MK Framework automatically generates RESTful routes based on your controller/handler structure:

| HTTP Method | Path               | Action  | Description            |
|-------------|-------------------|---------|------------------------|
| GET         | /todos            | index   | List all todos         |
| GET         | /todos/:id        | show    | Get a single todo      |
| POST        | /todos            | create  | Create a new todo      |
| POST        | /todos/:id        | update  | Update an existing todo |
| POST        | /todos/:id/delete | delete  | Delete a todo          |

> **Note**: MK Framework uses POST for update and delete operations rather than PUT/PATCH and DELETE HTTP methods.

## Nested Resources

You can create nested resources to represent relationships:

```ruby
# In your app.rb or a configuration file
TodoApp.register_nested_resource('projects', 'todos')
```

This creates nested routes:

| HTTP Method | Path                          | Action  | Description                       |
|-------------|------------------------------|---------|-----------------------------------|
| GET         | /projects/:project_id/todos  | index   | List todos for a specific project |
| POST        | /projects/:project_id/todos  | create  | Create a todo for a specific project |

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

### Testing - Sample Spec Cases

See docs/testing.md 

https://github.com/makevoid/mk_framework/blob/main/docs/testing.md

## Key Concepts

### Controllers vs Handlers

1. **Controllers**: 
   - Handle data retrieval and preparation
   - Return data to be processed by handlers
   - Focus on business logic
   - Execute BEFORE any model save operations

2. **Handlers**:
   - Process controller results
   - Format responses
   - Set HTTP status codes
   - Handle success/error conditions
   - Execute AFTER controller logic
   - Perform model save operations

### Success and Error Handling

For create, update, and delete operations, handlers must define success and error blocks:

```ruby
handler do |r|
  success do |r|
    # Code that runs when model.save succeeds
    # Set success status codes and format response
  end

  error do |r|
    # Code that runs when model.save fails
    # Set error status codes and format error response
  end
end
```

## License

MIT License
