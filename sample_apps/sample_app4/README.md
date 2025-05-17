# Kanban Board API with Cards and Comments

A RESTful API for managing kanban cards and comments built with the MK Framework, a lightweight Ruby web framework based on Roda.

## Overview

This application demonstrates a clean separation of concerns with a RESTful architecture:

- **Controllers**: Handle data retrieval and business logic
- **Handlers**: Format responses and set HTTP status codes
- **Models**: Define data structure and validation rules
- **Nested Resources**: Parent-child relationships between resources (cards and comments)

## Features

- Create, read, update and delete kanban cards
- Move cards between status columns (Todo, In Progress, Done)
- Add, view, edit and delete comments on cards
- Nested resource structure (comments belong to cards)
- Input validation on all resources
- JSON response formatting
- SQLite database storage
- RESTful API design
- Recursive data serialization

## Installation

```bash
# Clone the repository
git clone <repository-url>
cd sample_app4

# Install dependencies
bundle install
```

## Development and Testing

IMPORTANT: Always use RSpec for testing and debugging rather than starting the server directly:

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/request/cards_spec.rb
```

## API Endpoints

### Cards Endpoints
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/cards` | GET | List all cards |
| `/cards/:id` | GET | Get a specific card with its comments |
| `/cards` | POST | Create a new card |
| `/cards/:id` | POST | Update a card |
| `/cards/:id/delete` | POST | Delete a card |

### Comments Endpoints
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/cards/:card_id/comments` | GET | List all comments for a card |
| `/cards/:card_id/comments` | POST | Create a new comment for a card |
| `/comments/:id` | GET | Get a specific comment |
| `/comments/:id` | POST | Update a comment |
| `/comments/:id/delete` | POST | Delete a comment |

### Request/Response Examples

#### List all cards

```
GET /cards
```

Response:
```json
[
  {
    "id": 1,
    "title": "Implement Login Form",
    "description": "Create a login form with email and password fields",
    "status": "Todo",
    "created_at": "2023-01-01T12:00:00Z",
    "updated_at": "2023-01-01T12:00:00Z"
  },
  {
    "id": 2,
    "title": "Setup Database Schema",
    "description": "Create initial database schema with users table",
    "status": "In Progress",
    "created_at": "2023-01-02T10:00:00Z",
    "updated_at": "2023-01-02T15:30:00Z"
  }
]
```

#### Get a specific card with comments

```
GET /cards/1
```

Response:
```json
{
  "card": {
    "id": 1,
    "title": "Implement Login Form",
    "description": "Create a login form with email and password fields",
    "status": "Todo",
    "created_at": "2023-01-01T12:00:00Z",
    "updated_at": "2023-01-01T12:00:00Z"
  },
  "comments": [
    {
      "id": 1,
      "card_id": 1,
      "content": "Don't forget to add validation",
      "author": "Alice",
      "created_at": "2023-01-01T14:00:00Z",
      "updated_at": "2023-01-01T14:00:00Z"
    },
    {
      "id": 2,
      "card_id": 1,
      "content": "We should add a remember me checkbox",
      "author": "Bob",
      "created_at": "2023-01-01T15:30:00Z",
      "updated_at": "2023-01-01T15:30:00Z"
    }
  ]
}
```

#### Create a new card

```
POST /cards
```

Request body:
```json
{
  "title": "Implement Logout Functionality",
  "description": "Add a logout button to the navbar",
  "status": "Todo"
}
```

Response:
```json
{
  "message": "Card created",
  "card": {
    "id": 3,
    "title": "Implement Logout Functionality",
    "description": "Add a logout button to the navbar",
    "status": "Todo",
    "created_at": "2023-01-03T09:00:00Z",
    "updated_at": "2023-01-03T09:00:00Z"
  }
}
```

#### Update a card

```
POST /cards/1
```

Request body:
```json
{
  "status": "In Progress"
}
```

Response:
```json
{
  "message": "Card updated",
  "card": {
    "id": 1,
    "title": "Implement Login Form",
    "description": "Create a login form with email and password fields",
    "status": "In Progress",
    "created_at": "2023-01-01T12:00:00Z",
    "updated_at": "2023-01-03T14:00:00Z"
  }
}
```

#### Delete a card

```
POST /cards/1/delete
```

Response:
```json
{
  "message": "Card deleted successfully",
  "card": {
    "id": 1,
    "title": "Implement Login Form",
    "description": "Create a login form with email and password fields",
    "status": "Todo",
    "created_at": "2023-01-01T12:00:00Z",
    "updated_at": "2023-01-01T12:00:00Z"
  }
}
```

## Architecture

The application follows a structured architecture:

1. **Models**:
   - `models/card.rb`: Defines the card schema and validation rules
   - `models/comment.rb`: Defines the comment schema and validation rules with relationship to cards

2. **Controllers**:
   - `routes/cards/controllers/`: Handle card-related business logic
   - `routes/comments/controllers/`: Handle comment-related business logic

3. **Handlers**:
   - `routes/cards/handlers/`: Format card responses and set HTTP status codes
   - `routes/comments/handlers/`: Format comment responses and set HTTP status codes

4. **Application**:
   - `app.rb`: Configures the database, sets up the application, and registers nested resources
   
5. **Framework Enhancements**:
   - Nested resource support for parent-child relationships
   - Recursive model serialization for complex data structures

## Testing

Run the test suite with:

```bash
bundle exec rspec
```

## Framework Notes

The MK Framework has some unique conventions:

- DELETE operations use POST to `/:resource/:id/delete` instead of DELETE method
- UPDATE operations use POST to `/:resource/:id` instead of PUT/PATCH
- Controllers handle data operations, handlers manage response formatting
- Nested resources are registered with the application using `register_nested_resource`
- Complex object hierarchies are automatically serialized recursively

### Comment Examples

#### List comments for a card

```
GET /cards/1/comments
```

Response:
```json
[
  {
    "id": 1,
    "card_id": 1,
    "content": "Don't forget to add validation",
    "author": "Alice",
    "created_at": "2023-01-01T14:00:00Z",
    "updated_at": "2023-01-01T14:00:00Z"
  },
  {
    "id": 2,
    "card_id": 1,
    "content": "We should add a remember me checkbox",
    "author": "Bob",
    "created_at": "2023-01-01T15:30:00Z",
    "updated_at": "2023-01-01T15:30:00Z"
  }
]
```

#### Create a comment on a card

```
POST /cards/1/comments
```

Request body:
```json
{
  "content": "Should we include a password strength indicator?",
  "author": "Charlie"
}
```

Response:
```json
{
  "message": "Comment created",
  "comment": {
    "id": 3,
    "card_id": 1,
    "content": "Should we include a password strength indicator?",
    "author": "Charlie",
    "created_at": "2023-01-03T09:00:00Z",
    "updated_at": "2023-01-03T09:00:00Z"
  }
}
```