# Blog Post API with Comments

A RESTful API for managing blog posts and comments built with the MK Framework, a lightweight Ruby web framework based on Roda.

## Overview

This application demonstrates a clean separation of concerns with a RESTful architecture:

- **Controllers**: Handle data retrieval and business logic
- **Handlers**: Format responses and set HTTP status codes
- **Models**: Define data structure and validation rules
- **Nested Resources**: Parent-child relationships between resources (posts and comments)

## Features

- Create, read, update and delete blog posts
- Add, view, edit and delete comments on posts
- Nested resource structure (comments belong to posts)
- Input validation on all resources
- JSON response formatting
- SQLite database storage
- RESTful API design
- Recursive data serialization

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

### Posts Endpoints
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/posts` | GET | List all posts |
| `/posts/:id` | GET | Get a specific post with its comments |
| `/posts` | POST | Create a new post |
| `/posts/:id` | POST | Update a post |
| `/posts/:id/delete` | POST | Delete a post |

### Comments Endpoints
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/posts/:post_id/comments` | GET | List all comments for a post |
| `/posts/:post_id/comments` | POST | Create a new comment for a post |
| `/comments/:id` | GET | Get a specific comment |
| `/comments/:id` | POST | Update a comment |
| `/comments/:id/delete` | POST | Delete a comment |

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

#### Get a specific post with comments

```
GET /posts/1
```

Response:
```json
{
  "post": {
    "id": 1,
    "title": "First Blog Post",
    "description": "This is the content of my first blog post",
    "created_at": "2023-01-01T12:00:00Z",
    "updated_at": "2023-01-01T12:00:00Z"
  },
  "comments": [
    {
      "id": 1,
      "post_id": 1,
      "content": "This is a great post!",
      "author": "Alice",
      "created_at": "2023-01-01T14:00:00Z",
      "updated_at": "2023-01-01T14:00:00Z"
    },
    {
      "id": 2,
      "post_id": 1,
      "content": "I learned a lot from this",
      "author": "Bob",
      "created_at": "2023-01-01T15:30:00Z",
      "updated_at": "2023-01-01T15:30:00Z"
    }
  ]
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

1. **Models**:
   - `models/post.rb`: Defines the post schema and validation rules
   - `models/comment.rb`: Defines the comment schema and validation rules with relationship to posts

2. **Controllers**:
   - `routes/posts/controllers/`: Handle post-related business logic
   - `routes/comments/controllers/`: Handle comment-related business logic

3. **Handlers**:
   - `routes/posts/handlers/`: Format post responses and set HTTP status codes
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

### New Comment Examples

#### List comments for a post

```
GET /posts/1/comments
```

Response:
```json
[
  {
    "id": 1,
    "post_id": 1,
    "content": "This is a great post!",
    "author": "Alice",
    "created_at": "2023-01-01T14:00:00Z",
    "updated_at": "2023-01-01T14:00:00Z"
  },
  {
    "id": 2,
    "post_id": 1,
    "content": "I learned a lot from this",
    "author": "Bob",
    "created_at": "2023-01-01T15:30:00Z",
    "updated_at": "2023-01-01T15:30:00Z"
  }
]
```

#### Create a comment on a post

```
POST /posts/1/comments
```

Request body:
```json
{
  "content": "Great article!",
  "author": "Charlie"
}
```

Response:
```json
{
  "message": "Comment created",
  "comment": {
    "id": 3,
    "post_id": 1,
    "content": "Great article!",
    "author": "Charlie",
    "created_at": "2023-01-03T09:00:00Z",
    "updated_at": "2023-01-03T09:00:00Z"
  }
}
```