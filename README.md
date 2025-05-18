# MK Framework

MK Framework is a lightweight, Ruby-based API framework inspired by Ruby on Rails' MVC pattern. It implements a Model-View-Handler (MVH) architecture for API development, where JSON responses serve as the "view" layer.

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
my_app/
├── app.rb
├── config.ru
├── models/
│   └── user.rb
└── routes/
    └── users/
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
require 'mk_framework'

# Set up database connection
DB = Sequel.connect('sqlite://my_database.db')

# Create your tables
DB.create_table? :users do
  primary_key :id
  String :name, null: false
  String :email, null: false, unique: true
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
end

# Require models
require_relative 'models/user'

# Create application instance
class MyApp < MK::Application
  # Setup CORS if needed
  register_cors_domain 'http://localhost:3000'
  
  # Set up logging
  setup_logger('log/application.log')
end
```

3. Set up your Rack configuration:

```ruby
# config.ru
require_relative 'app'

run MyApp
```

### Define Your Models

```ruby
# models/user.rb
class User < Sequel::Model
  plugin :validation_helpers

  def validate
    super
    validates_presence [:name, :email]
    validates_unique :email
  end
end
```

### Define Controllers and Handlers

#### Index (List all resources)

```ruby
# routes/users/controllers/index.rb
class UsersIndexController < MK::Controller
  route do |r|
    User.all
  end
end
```

```ruby
# routes/users/handlers/index.rb
class UsersIndexHandler < MK::Handler
  handler do |r|
    model.map(&:to_hash)
  end
end
```

#### Show (Get a single resource)

```ruby
# routes/users/controllers/show.rb
class UsersShowController < MK::Controller
  route do |r|
    User[r.params.fetch('id')]
  end
end
```

```ruby
# routes/users/handlers/show.rb
class UsersShowHandler < MK::Handler
  handler do |r|
    model.to_hash
  end
end
```

#### Create

```ruby
# routes/users/controllers/create.rb
class UsersCreateController < MK::Controller
  route do |r|
    User.new(
      name: r.params['name'],
      email: r.params['email']
    )
  end
end
```

```ruby
# routes/users/handlers/create.rb
class UsersCreateHandler < MK::Handler
  handler do |r|
    success do |r|
      r.response.status = 201
      {
        message: "User created",
        user: model.to_hash
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
# routes/users/controllers/update.rb
class UsersUpdateController < MK::Controller
  route do |r|
    user = User[r.params.fetch('id')]
    
    r.halt(404, { message: "User not found" }) if user.nil?

    user.name = r.params['name'] if r.params.key?('name')
    user.email = r.params['email'] if r.params.key?('email')
    
    user
  end
end
```

```ruby
# routes/users/handlers/update.rb
class UsersUpdateHandler < MK::Handler
  handler do |r|
    success do |r|
      {
        message: "User updated",
        user: model.to_hash
      }
    end

    error do |r|
      r.response.status = 400
      {
        error: "Validation failed",
        details: model.errors
      }
    end
  end
end
```

#### Delete

```ruby
# routes/users/controllers/delete.rb
class UsersDeleteController < MK::Controller
  route do |r|
    user = User[r.params.fetch('id')]
    
    r.halt(404, { message: "User not found" }) if user.nil?
    
    user
  end
end
```

```ruby
# routes/users/handlers/delete.rb
class UsersDeleteHandler < MK::Handler
  handler do |r|
    success do |r|
      {
        message: "User deleted successfully",
        user: model.to_hash
      }
    end

    error do |r|
      r.response.status = 500
      {
        error: "Failed to delete user"
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
| GET         | /users            | index   | List all users         |
| GET         | /users/:id        | show    | Get a single user      |
| POST        | /users            | create  | Create a new user      |
| POST        | /users/:id        | update  | Update an existing user |
| POST        | /users/:id/delete | delete  | Delete a user          |

> **Note**: MK Framework uses POST for update and delete operations rather than PUT/PATCH and DELETE HTTP methods.

## Nested Resources

You can create nested resources to represent relationships:

```ruby
# In your app.rb or a configuration file
MyApp.register_nested_resource('users', 'posts')
```

This creates nested routes:

| HTTP Method | Path                      | Action  | Description                  |
|-------------|--------------------------|---------|------------------------------|
| GET         | /users/:user_id/posts    | index   | List posts for a specific user |
| POST        | /users/:user_id/posts    | create  | Create a post for a specific user |

## Testing

MK Framework includes test helpers for RSpec and Rack::Test:

```ruby
# spec/spec_helper.rb
require 'rspec'
require 'rack/test'
require 'json'
require_relative '../app'
require_relative '/path/to/mk_framework/lib_spec/mk_framework_spec_helpers'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  
  def app
    MyApp.app
  end
  
  config.include MK::Framework::Spec
end
```

In your tests:

```ruby
# spec/request/users_spec.rb
require 'spec_helper'

describe "Users" do
  describe "GET /users" do
    it "returns all users" do
      get '/users'
      
      expect(last_response.status).to eq 200
      expect(resp.length).to eq User.count
    end
  end
  
  # More tests...
end
```

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