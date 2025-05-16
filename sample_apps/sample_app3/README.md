# Blog Post API

A RESTful API for managing blog posts built with the MK Framework, a lightweight Ruby web framework based on Roda.

## Overview

This application demonstrates a clean separation of concerns with a RESTful architecture:

- **Controllers**: Handle data retrieval and business logic
- **Handlers**: Format responses and set HTTP status codes
- **Models**: Define data structure and validation rules

## Features

- Create, read, update and delete blog posts
- Input validation
- JSON response formatting
- SQLite database storage
- RESTful API design

## Installation

```bash
# Clone the repository
git clone <repository-url>
cd sample_app3

# Install dependencies
bundle install
```

## Development and Testing

IMPORTANT: Always use RSpec for testing and debugging rather than starting the server directly:

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/request/posts_spec.rb
```

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/posts` | GET | List all posts |
| `/posts/:id` | GET | Get a specific post |
| `/posts` | POST | Create a new post |
| `/posts/:id` | POST | Update a post |
| `/posts/:id/delete` | POST | Delete a post |

### Request/Response Examples

#### List all posts

```
GET /posts
```

Response:
```json
[
  {
    "id": 1,
    "title": "First Blog Post",
    "description": "This is the content of my first blog post",
    "created_at": "2023-01-01T12:00:00Z",
    "updated_at": "2023-01-01T12:00:00Z"
  },
  {
    "id": 2,
    "title": "Second Blog Post",
    "description": "This is the content of my second blog post",
    "created_at": "2023-01-02T10:00:00Z",
    "updated_at": "2023-01-02T15:30:00Z"
  }
]
```

#### Get a specific post

```
GET /posts/1
```

Response:
```json
{
  "id": 1,
  "title": "First Blog Post",
  "description": "This is the content of my first blog post",
  "created_at": "2023-01-01T12:00:00Z",
  "updated_at": "2023-01-01T12:00:00Z"
}
```

#### Create a new post

```
POST /posts
```

Request body:
```json
{
  "title": "New Blog Post",
  "description": "This is the content of my new blog post"
}
```

Response:
```json
{
  "message": "Post created",
  "post": {
    "id": 3,
    "title": "New Blog Post",
    "description": "This is the content of my new blog post",
    "created_at": "2023-01-03T09:00:00Z",
    "updated_at": "2023-01-03T09:00:00Z"
  }
}
```

#### Update a post

```
POST /posts/1
```

Request body:
```json
{
  "title": "Updated Blog Post Title"
}
```

Response:
```json
{
  "message": "Post updated",
  "post": {
    "id": 1,
    "title": "Updated Blog Post Title",
    "description": "This is the content of my first blog post",
    "created_at": "2023-01-01T12:00:00Z",
    "updated_at": "2023-01-03T14:00:00Z"
  }
}
```

#### Delete a post

```
POST /posts/1/delete
```

Response:
```json
{
  "message": "Post deleted successfully",
  "post": {
    "id": 1,
    "title": "First Blog Post",
    "description": "This is the content of my first blog post",
    "created_at": "2023-01-01T12:00:00Z",
    "updated_at": "2023-01-01T12:00:00Z"
  }
}
```

## Architecture

The application follows a structured architecture:

1. **Models** (`models/post.rb`): Define the data schema and validation rules
2. **Controllers** (`routes/posts/controllers/`): Handle business logic and data operations
3. **Handlers** (`routes/posts/handlers/`): Format responses and set HTTP status codes
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