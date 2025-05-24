# Hotel Booking and Todo List API

A RESTful API for managing hotel bookings and todo items, built with the MK Framework, a lightweight Ruby web framework based on Roda.

## Overview

This application demonstrates a clean separation of concerns with a RESTful architecture:

- **Controllers**: Handle data retrieval and business logic
- **Handlers**: Format responses and set HTTP status codes
- **Models**: Define data structure and validation rules

## Features

- **Todo Management**: Create, read, update, and delete todo items.
- **Hotel Bookings**:
  - Manage bookings for two types of rooms:
    - "room_for_2": Double Room (capacity: 2 people)
    - "room_for_3": Triple Room (capacity: 3 people)
  - Create, read, update, and delete bookings.
  - Validation for room capacity.
  - Validation to prevent overlapping bookings for the same room type.
- Input validation for all resources.
- JSON response formatting.
- SQLite database storage.
- RESTful API design.

## Installation

```bash
# Clone the repository
git clone <repository-url>
cd <repository-directory>

# Install dependencies
bundle install

# Start the server
bundle exec rackup
```

The server will start on http://localhost:9292 (default for rackup).

## API Endpoints

### Todos API

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/todos` | GET | List all todos |
| `/todos/:id` | GET | Get a specific todo |
| `/todos` | POST | Create a new todo |
| `/todos/:id` | POST | Update a todo |
| `/todos/:id/delete` | POST | Delete a todo |

### Bookings API

The hotel has two room types:
- `room_for_2`: Double Room, capacity 2 people.
- `room_for_3`: Triple Room, capacity 3 people.

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/bookings` | GET | List all bookings |
| `/bookings/:id` | GET | Get a specific booking |
| `/bookings` | POST | Create a new booking |
| `/bookings/:id` | POST | Update a booking |
| `/bookings/:id/delete` | POST | Delete a booking |

## Request/Response Examples

### List all todos
```
GET /todos
```

Response: (Example)
```json
[
  {
    "id": 1,
    "title": "Buy groceries",
    "description": "Milk, eggs, bread",
    "completed": false,
    "created_at": "2023-01-01T12:00:00Z",
    "updated_at": "2023-01-01T12:00:00Z"
  }
]
```

### Create a new booking
```
POST /bookings
```

Request body:
```json
{
  "room_type": "room_for_2",
  "guest_name": "John Doe",
  "num_guests": 2,
  "start_date": "2024-12-20",
  "end_date": "2024-12-24"
}
```

Successful Response (201 Created):
```json
{
  "message": "Booking created",
  "booking": {
    "id": 1,
    "room_type": "room_for_2",
    "guest_name": "John Doe",
    "num_guests": 2,
    "start_date": "2024-12-20",
    "end_date": "2024-12-24",
    "created_at": "2024-07-29T10:00:00Z",
    "updated_at": "2024-07-29T10:00:00Z"
  }
}
```

Validation Error Response (422 Unprocessable Entity): (e.g. overlapping booking)
```json
{
  "error": "Validation failed",
  "details": {
    "base": ["The room 'Double Room (2 people)' is already booked for the selected dates: 2024-12-20 to 2024-12-24."]
  }
}
```

### Get a specific booking
```
GET /bookings/1
```

Response:
```json
{
  "id": 1,
  "room_type": "room_for_2",
  "guest_name": "John Doe",
  "num_guests": 2,
  "start_date": "2024-12-20",
  "end_date": "2024-12-24",
  "created_at": "2024-07-29T10:00:00Z",
  "updated_at": "2024-07-29T10:00:00Z"
}
```

### Update a booking
```
POST /bookings/1
```

Request body (e.g., changing number of guests):
```json
{
  "num_guests": 1
}
```

Response:
```json
{
  "message": "Booking updated",
  "booking": {
    "id": 1,
    "room_type": "room_for_2",
    "guest_name": "John Doe",
    "num_guests": 1,
    "start_date": "2024-12-20",
    "end_date": "2024-12-24",
    "created_at": "2024-07-29T10:00:00Z",
    "updated_at": "2024-07-29T10:05:00Z"
  }
}
```

### Delete a booking
```
POST /bookings/1/delete
```

Response:
```json
{
  "message": "Booking deleted successfully",
  "booking": {
    "id": 1,
    "room_type": "room_for_2",
    "guest_name": "John Doe",
    "num_guests": 1,
    "start_date": "2024-12-20",
    "end_date": "2024-12-24",
    "created_at": "2024-07-29T10:00:00Z",
    "updated_at": "2024-07-29T10:05:00Z"
  }
}
```

## Architecture

The application follows a structured architecture:

1. **Models** (`models/todo.rb`, `models/booking.rb`): Define data schemas and validation rules.
2. **Controllers** (`routes/todos/controllers/`, `routes/bookings/controllers/`): Handle business logic and data operations.
3. **Handlers** (`routes/todos/handlers/`, `routes/bookings/handlers/`): Format responses and set HTTP status codes.
4. **Application** (`app.rb`): Configure the database, CORS, and set up resource routing.

## Testing

Run the test suite with:

```bash
bundle exec rspec
```

To run tests for a specific file:

```bash
bundle exec rspec spec/request/bookings_spec.rb
bundle exec rspec spec/request/todos_spec.rb
```

## Framework Notes

The MK Framework has some unique conventions:

- DELETE operations use POST to `/:resource/:id/delete` instead of the HTTP DELETE method.
- UPDATE operations use POST to `/:resource/:id` instead of HTTP PUT/PATCH methods.
- Controllers handle data operations; Handlers manage response formatting.