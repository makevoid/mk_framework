# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands
- Run server: `bundle exec rackup`
- Install dependencies: `bundle install`
- Run tests: `bundle exec rspec`
- Run single test: `bundle exec rspec spec/path/to/file_spec.rb:LINE_NUMBER`
- Linting: `bundle exec rubocop`

## Application Architecture
This is a RESTful Todo API built with the MK Framework, a lightweight Ruby web framework based on Roda. The application follows a clean separation of concerns:

- **Models**: Define data schema and validation rules using Sequel::Model (`models/todo.rb`)
- **Controllers**: Handle business logic and data operations (`routes/todos/controllers/`)
- **Handlers**: Format responses and set HTTP status codes (`routes/todos/handlers/`)
- **Application**: Main entry point that configures database and routes (`app.rb`)

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
- Framework uses a consistent RESTful routing pattern:
  - GET /todos - index (list all)
  - GET /todos/:id - show (get one)
  - POST /todos - create
  - POST /todos/:id - update
  - POST /todos/:id/delete - delete

## Testing
- Tests use RSpec with Rack::Test for HTTP request simulation
- Test helpers are available in the MK::Framework::Spec module
- Tests should clean up database state between examples (using `before` blocks)
- Response data can be accessed through the `resp` helper method which parses JSON