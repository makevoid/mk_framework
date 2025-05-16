# MK Framework Guidelines

## Commands
- Install dependencies: `bundle install`
- Run tests: `bundle exec rspec`
- Run single test: `bundle exec rspec spec/path/to/file_spec.rb:LINE_NUMBER`
- Linting: `bundle exec rubocop`

## IMPORTANT
- NEVER run the server directly with `rackup` or `bundle exec rackup`
- Always use RSpec for testing and debugging
- Use `bundle exec rspec` to run all tests
- Use `bundle exec rspec spec/request/posts_spec.rb` to test specific endpoints

## Code Style
- Include `# frozen_string_literal: true` at the top of each Ruby file
- Follow Ruby naming conventions: snake_case for methods/variables, CamelCase for classes
- RESTful architecture with controller/handler separation
- Controllers handle data retrieval and business logic
- Handlers handle response formatting and HTTP status
- Models use Sequel::Model with validation_helpers plugin
- Error handling: use r.halt for interrupting execution, handlers for formatting errors
- Resource routing follows RESTful convention (index, show, create, update, delete)
- Keep methods small and focused on a single responsibility
- Explicit requires over autoloading
- Use fetch for required parameters, direct access for optional ones

## HTTP Method Conventions
- Framework uses non-standard HTTP method conventions for some operations
- DELETE operations use POST to "/:resource/:id/delete" instead of DELETE method
- UPDATE operations use POST to "/:resource/:id" instead of PUT/PATCH
- Test both standard (delete "/todos/:id") and framework-specific (post "/todos/:id/delete") methods
- Do not standardize HTTP methods across tests as this dual approach validates both patterns

## Route Structure
- Framework uses a consistent RESTful routing pattern similar to Ruby on Rails and Sinatra:
  - GET /todos - index (list all)
  - GET /todos/:id - show (get one)
  - POST /todos - create
  - POST /todos/:id - update
  - POST /todos/:id/delete - delete