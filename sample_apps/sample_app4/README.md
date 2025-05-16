# Kanban Board API with Cards and Comments

A RESTful API for managing a kanban board with cards and comments built with the MK Framework, a lightweight Ruby web framework based on Roda.

## Overview

This application implements a simple kanban board with the following features:
- Three fixed columns: "todo", "in_progress", and "done"
- Cards with title, description, and status
- Comments can be added to any card

The application demonstrates a clean separation of concerns with a RESTful architecture:

- **Controllers**: Handle data retrieval and business logic
- **Handlers**: Format responses and set HTTP status codes
- **Models**: Define data structure and validation rules
- **Nested Resources**: Parent-child relationships between resources (cards and comments)

## Features

- Create, read, update and delete cards
- Move cards between columns by updating their status
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
| `/cards/:id` | POST | Update a card (including changing its status) |
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
{
  "cards": [
    {
      "id": 1,
      "title": "Implement authentication",
      "description": "Add user login and registration",
      "status": "todo",
      "created_at": "2023-01-01T12:00:00Z",
      "updated_at": "2023-01-01T12:00:00Z"
    },
    {
      "id": 2,
      "title": "Add dark mode support",
      "description": "Implement dark mode for the UI",
      "status": "in_progress",
      "created_at": "2023-01-02T10:00:00Z",
      "updated_at": "2023-01-02T15:30:00Z"
    },
    {
      "id": 3,
      "title": "Fix navigation bug",
      "description": "Fix the issue with the sidebar navigation",
      "status": "done",
      "created_at": "2023-01-03T09:00:00Z",
      "updated_at": "2023-01-03T14:00:00Z"
    }
  ]
}
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
    "title": "Implement authentication",
    "description": "Add user login and registration",
    "status": "todo",
    "created_at": "2023-01-01T12:00:00Z",
    "updated_at": "2023-01-01T12:00:00Z"
  },
  "comments": [
    {
      "id": 1,
      "card_id": 1,
      "content": "We should use JWT for this",
      "author": "Alice",
      "created_at": "2023-01-01T14:00:00Z",
      "updated_at": "2023-01-01T14:00:00Z"
    },
    {
      "id": 2,
      "card_id": 1,
      "content": "Let's add social login too",
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
  "title": "Add image upload feature",
  "description": "Implement image uploading for users",
  "status": "todo"
}
```

Response:
```json
{
  "message": "Card created",
  "card": {
    "id": 4,
    "title": "Add image upload feature",
    "description": "Implement image uploading for users",
    "status": "todo",
    "created_at": "2023-01-04T09:00:00Z",
    "updated_at": "2023-01-04T09:00:00Z"
  }
}
```

#### Update a card (moving to a different column)

```
POST /cards/1
```

Request body:
```json
{
  "status": "in_progress"
}
```

Response:
```json
{
  "message": "Card updated",
  "card": {
    "id": 1,
    "title": "Implement authentication",
    "description": "Add user login and registration",
    "status": "in_progress",
    "created_at": "2023-01-01T12:00:00Z",
    "updated_at": "2023-01-04T14:00:00Z"
  }
}
```

#### Delete a card

```
POST /cards/3/delete
```

Response:
```json
{
  "message": "Card deleted successfully",
  "card": {
    "id": 3,
    "title": "Fix navigation bug",
    "description": "Fix the issue with the sidebar navigation",
    "status": "done",
    "created_at": "2023-01-03T09:00:00Z",
    "updated_at": "2023-01-03T14:00:00Z"
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
    "content": "We should use JWT for this",
    "author": "Alice",
    "created_at": "2023-01-01T14:00:00Z",
    "updated_at": "2023-01-01T14:00:00Z"
  },
  {
    "id": 2,
    "card_id": 1,
    "content": "Let's add social login too",
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
  "content": "This looks good to me",
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
    "content": "This looks good to me",
    "author": "Charlie",
    "created_at": "2023-01-04T09:00:00Z",
    "updated_at": "2023-01-04T09:00:00Z"
  }
}
```