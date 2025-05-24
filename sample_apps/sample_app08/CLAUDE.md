# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands
- Run server: `bundle exec rackup`
- Install dependencies: `bundle install`
- Run tests: `bundle exec rspec`
- Run single test: `bundle exec rspec spec/path/to/file_spec.rb:LINE_NUMBER`
- Linting: `bundle exec rubocop`

## Application Architecture
This is a RESTful E-commerce API built with the MK Framework, a lightweight Ruby web framework based on Roda. The application follows a clean separation of concerns:

- **Models**: Define data schema and validation rules using Sequel::Model (`models/`)
  - `Product`: Product catalog with inventory management
  - `Cart`: Session-based shopping cart
  - `CartItem`: Individual items in shopping carts
  - `Order`: Order management and checkout
- **Controllers**: Handle business logic and data operations (`routes/*/controllers/`)
- **Handlers**: Format responses and set HTTP status codes (`routes/*/handlers/`)
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

## API Endpoints

### Products
- GET /products - List all active products (with optional filtering)
- GET /products/:id - Get specific product
- POST /products - Create new product
- POST /products/:id - Update product
- POST /products/:id/delete - Delete product

### Cart
- GET /cart/:session_id - Get cart contents
- POST /cart/:session_id/add - Add item to cart
- POST /cart/:session_id/items/:item_id - Update cart item quantity
- POST /cart/:session_id/items/:item_id/delete - Remove item from cart
- POST /cart/:session_id/clear - Clear entire cart

### Checkout
- POST /checkout - Create order from cart

## Business Logic
- Cart is session-based (no user authentication required)
- Stock validation occurs during cart operations and checkout
- Orders are created in database transactions for consistency
- Stock is automatically reduced when orders are placed
- Products can be soft-deleted by setting `active` to false

## Testing
- Tests use RSpec with Rack::Test for HTTP request simulation
- Test helpers are available in the MK::Framework::Spec module
- Tests should clean up database state between examples (using `before` blocks)
- Response data can be accessed through the `resp` helper method which parses JSON