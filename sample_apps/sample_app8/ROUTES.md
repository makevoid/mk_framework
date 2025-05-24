# API Routes Documentation

This document details all API routes available in the Todo application, along with guidance for implementing a Next.js frontend using this API.

## Available Routes

### 1. List All Todos
- **Endpoint**: `GET /todos`
- **Controller**: `TodosIndexController`
- **Description**: Returns all todos in the database
- **Response Format**:
  ```json
  {
    "todos": [
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
    ],
    "custom_field": "Custom value for index"
  }
  ```
- **Status Codes**:
  - `200 OK`: Successfully retrieved todos

### 2. Get a Specific Todo
- **Endpoint**: `GET /todos/:id`
- **Controller**: `TodosShowController`
- **Description**: Returns a specific todo by ID
- **URL Parameters**:
  - `id`: The ID of the todo to retrieve
- **Response Format**:
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
- **Status Codes**:
  - `200 OK`: Successfully retrieved todo
  - `404 Not Found`: Todo with specified ID does not exist

### 3. Create a New Todo
- **Endpoint**: `POST /todos`
- **Controller**: `TodosCreateController`
- **Description**: Creates a new todo
- **Request Body**:
  ```json
  {
    "title": "Learn Ruby",
    "description": "Study MK Framework", // Optional
    "completed": false // Optional, defaults to false
  }
  ```
- **Response Format**:
  ```json
  {
    "message": "Todo created",
    "todo": {
      "id": 3,
      "title": "Learn Ruby",
      "description": null,
      "completed": false,
      "created_at": "2023-01-03T09:00:00Z",
      "updated_at": "2023-01-03T09:00:00Z"
    },
    "custom_field": "Custom value for create"
  }
  ```
- **Status Codes**:
  - `201 Created`: Successfully created todo
  - `422 Unprocessable Entity`: Validation failed

### 4. Update a Todo
- **Endpoint**: `POST /todos/:id`
- **Controller**: `TodosUpdateController`
- **Description**: Updates an existing todo
- **URL Parameters**:
  - `id`: The ID of the todo to update
- **Request Body** (all fields optional):
  ```json
  {
    "title": "Updated title",
    "completed": true
  }
  ```
- **Response Format**:
  ```json
  {
    "message": "Todo updated",
    "todo": {
      "id": 1,
      "title": "Updated title",
      "description": "Milk, eggs, bread",
      "completed": true,
      "created_at": "2023-01-01T12:00:00Z",
      "updated_at": "2023-01-03T14:00:00Z"
    }
  }
  ```
- **Status Codes**:
  - `200 OK`: Successfully updated todo
  - `404 Not Found`: Todo with specified ID does not exist
  - `400 Bad Request`: Validation failed

### 5. Delete a Todo
- **Endpoint**: `POST /todos/:id/delete`
- **Controller**: `TodosDeleteController`
- **Description**: Deletes an existing todo
- **URL Parameters**:
  - `id`: The ID of the todo to delete
- **Response Format**:
  ```json
  {
    "message": "Todo deleted successfully",
    "todo": {
      "id": 1,
      "title": "Buy groceries",
      "description": "Milk, eggs, bread",
      "completed": false,
      "created_at": "2023-01-01T12:00:00Z",
      "updated_at": "2023-01-01T12:00:00Z"
    },
    "custom_field": "Custom value for delete"
  }
  ```
- **Status Codes**:
  - `200 OK`: Successfully deleted todo
  - `404 Not Found`: Todo with specified ID does not exist
  - `500 Internal Server Error`: Failed to delete todo

## Framework Notes
- The MK Framework uses non-standard HTTP method conventions:
  - DELETE operations use POST to `/:resource/:id/delete` instead of DELETE method
  - UPDATE operations use POST to `/:resource/:id` instead of PUT/PATCH
- Standard HTTP methods may still work in tests but are not guaranteed in the application
