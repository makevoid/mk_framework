# Calendar Events API

A RESTful API for managing calendar events built with the MK Framework, a lightweight Ruby web framework based on Roda.

## Overview

This application demonstrates a clean separation of concerns with a RESTful architecture:

- **Controllers**: Handle data retrieval and business logic
- **Handlers**: Format responses and set HTTP status codes
- **Models**: Define data structure and validation rules

## Features

- Create, read, update and delete calendar events
- Support for all-day events and location information
- Input validation
- JSON response formatting
- SQLite database storage
- RESTful API design

## Installation

```bash
# Clone the repository
git clone <repository-url>
cd sample_app7

# Install dependencies
bundle install

# Start the server
bundle exec rackup
```

The server will start on http://localhost:9292

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/events` | GET | List all events |
| `/events/:id` | GET | Get a specific event |
| `/events` | POST | Create a new event |
| `/events/:id` | POST | Update an event |
| `/events/:id/delete` | POST | Delete an event |

### Request/Response Examples

#### List all events

```
GET /events
```

Response:
```json
[
  {
    "id": 1,
    "title": "Team Meeting",
    "description": "Weekly team sync",
    "start_time": "2024-05-20T10:00:00Z",
    "end_time": "2024-05-20T11:00:00Z",
    "location": "Conference Room A",
    "all_day": false,
    "created_at": "2024-05-18T14:00:00Z",
    "updated_at": "2024-05-18T14:00:00Z"
  },
  {
    "id": 2,
    "title": "Company Holiday",
    "description": "Annual company day off",
    "start_time": "2024-05-27T00:00:00Z",
    "end_time": "2024-05-27T23:59:59Z",
    "location": null,
    "all_day": true,
    "created_at": "2024-05-18T14:30:00Z",
    "updated_at": "2024-05-18T14:30:00Z"
  }
]
```

#### Get a specific event

```
GET /events/1
```

Response:
```json
{
  "id": 1,
  "title": "Team Meeting",
  "description": "Weekly team sync",
  "start_time": "2024-05-20T10:00:00Z",
  "end_time": "2024-05-20T11:00:00Z",
  "location": "Conference Room A",
  "all_day": false,
  "created_at": "2024-05-18T14:00:00Z",
  "updated_at": "2024-05-18T14:00:00Z"
}
```

#### Create a new event

```
POST /events
```

Request body:
```json
{
  "title": "Client Meeting",
  "description": "Discuss project timeline",
  "start_time": "2024-05-25T09:00:00Z",
  "end_time": "2024-05-25T10:00:00Z",
  "location": "Conference Room B"
}
```

Response:
```json
{
  "message": "Event created",
  "event": {
    "id": 3,
    "title": "Client Meeting",
    "description": "Discuss project timeline",
    "start_time": "2024-05-25T09:00:00Z",
    "end_time": "2024-05-25T10:00:00Z",
    "location": "Conference Room B",
    "all_day": false,
    "created_at": "2024-05-18T15:00:00Z",
    "updated_at": "2024-05-18T15:00:00Z"
  }
}
```

#### Update an event

```
POST /events/1
```

Request body:
```json
{
  "location": "Virtual Meeting",
  "description": "Updated description with meeting link"
}
```

Response:
```json
{
  "message": "Event updated",
  "event": {
    "id": 1,
    "title": "Team Meeting",
    "description": "Updated description with meeting link",
    "start_time": "2024-05-20T10:00:00Z",
    "end_time": "2024-05-20T11:00:00Z",
    "location": "Virtual Meeting",
    "all_day": false,
    "created_at": "2024-05-18T14:00:00Z",
    "updated_at": "2024-05-18T15:15:00Z"
  }
}
```

#### Delete an event

```
POST /events/1/delete
```

Response:
```json
{
  "message": "Event deleted successfully",
  "event": {
    "id": 1,
    "title": "Team Meeting",
    "description": "Updated description with meeting link",
    "start_time": "2024-05-20T10:00:00Z",
    "end_time": "2024-05-20T11:00:00Z",
    "location": "Virtual Meeting",
    "all_day": false,
    "created_at": "2024-05-18T14:00:00Z",
    "updated_at": "2024-05-18T15:15:00Z"
  }
}
```

## Architecture

The application follows a structured architecture:

1. **Models** (`models/event.rb`): Define the data schema and validation rules
2. **Controllers** (`routes/events/controllers/`): Handle business logic and data operations
3. **Handlers** (`routes/events/handlers/`): Format responses and set HTTP status codes
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