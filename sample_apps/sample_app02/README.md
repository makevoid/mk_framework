# Todo List API

A RESTful API for managing todo items built with the MK Framework, a lightweight Ruby web framework based on Roda.

## Overview

This application demonstrates a clean separation of concerns with a RESTful architecture:

- **Controllers**: Handle data retrieval and business logic
- **Handlers**: Format responses and set HTTP status codes
- **Models**: Define data structure and validation rules

## Features

- Create, read, update and delete todo items
- Input validation
- JSON response formatting
- SQLite database storage
- RESTful API design

## Installation

```bash
# Clone the repository
git clone <repository-url>
cd sample_app2

# Install dependencies
bundle install

# Start the server
bundle exec rackup
```

The server will start on http://localhost:9292

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/todos` | GET | List all todos |
| `/todos/:id` | GET | Get a specific todo |
| `/todos` | POST | Create a new todo |
| `/todos/:id` | POST | Update a todo |
| `/todos/:id/delete` | POST | Delete a todo |

### Request/Response Examples

#### List all todos

```
GET /todos
```

Response:
```json
[
  {
    "id": 1,
    "title": "Buy groceries",
    "description": "Milk, eggs, bread",
    "completed": false,
    "created_at": "2023-01-01T12:00:00Z",
    "updated_at": "2023-01-01T12:00:00Z"
  },
  {
    "id": 2,
    "title": "Finish project",
    "description": "Complete the todo API",
    "completed": true,
    "created_at": "2023-01-02T10:00:00Z",
    "updated_at": "2023-01-02T15:30:00Z"
  }
]
```

#### Get a specific todo

```
GET /todos/1
```

Response:
```json
{
  "id": 1,
  "title": "Buy groceries",
  "description": "Milk, eggs, bread",
  "completed": false,
  "created_at": "2023-01-01T12:00:00Z",
  "updated_at": "2023-01-01T12:00:00Z"
}
```

#### Create a new todo

```
POST /todos
```

Request body:
```json
{
  "title": "Learn Ruby",
  "description": "Study MK Framework",
  "completed": false
}
```

Response:
```json
{
  "id": 3,
  "title": "Learn Ruby",
  "description": "Study MK Framework",
  "completed": false,
  "created_at": "2023-01-03T09:00:00Z",
  "updated_at": "2023-01-03T09:00:00Z"
}
```

#### Update a todo

```
POST /todos/1
```

Request body:
```json
{
  "completed": true
}
```

Response:
```json
{
  "id": 1,
  "title": "Buy groceries",
  "description": "Milk, eggs, bread",
  "completed": true,
  "created_at": "2023-01-01T12:00:00Z",
  "updated_at": "2023-01-03T14:00:00Z"
}
```

#### Delete a todo

```
POST /todos/1/delete
```

Response:
```json
{
  "success": true
}
```

## Architecture

The application follows a structured architecture:

1. **Models** (`models/todo.rb`): Define the data schema and validation rules
2. **Controllers** (`routes/todos/controllers/`): Handle business logic and data operations
3. **Handlers** (`routes/todos/handlers/`): Format responses and set HTTP status codes
4. **Application** (`app.rb`): Configure the database and set up the application

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