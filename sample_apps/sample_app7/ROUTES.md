# Calendar Events API Routes

This document provides detailed information about the Calendar Events API routes and how to implement a frontend application using Next.js to interact with this API.

## API Base URL

When running locally, the API is accessible at:
```
http://localhost:3000
```

## Available Routes

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/events` | GET | List all events |
| `/events/:id` | GET | Get a specific event |
| `/events` | POST | Create a new event |
| `/events/:id` | POST | Update an event |
| `/events/:id/delete` | POST | Delete an event |

> **Note:** This API uses non-standard HTTP methods for some operations. DELETE operations use POST to `/:resource/:id/delete` and UPDATE operations use POST to `/:resource/:id` instead of the standard HTTP methods.

## Route Details

### GET `/events`

Retrieves a list of all events.

**Response:**
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

### GET `/events/:id`

Retrieves a specific event by ID.

**Response:**
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

### POST `/events`

Creates a new event.

**Request Body:**
```json
{
  "title": "Client Meeting",
  "description": "Discuss project timeline",
  "start_time": "2024-05-25T09:00:00Z",
  "end_time": "2024-05-25T10:00:00Z",
  "location": "Conference Room B",
  "all_day": false
}
```

**Response:**
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

### POST `/events/:id`

Updates an existing event.

**Request Body:**
```json
{
  "location": "Virtual Meeting",
  "description": "Updated description with meeting link"
}
```

**Response:**
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

### POST `/events/:id/delete`

Deletes an event.

**Response:**
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

## Error Responses

### 404 Not Found
```json
{
  "error": "Event not found"
}
```

### 422 Validation Error
```json
{
  "error": "Validation failed",
  "details": {
    "title": ["title is required"]
  }
}
```

### 400 Bad Request
```json
{
  "error": "Validation failed!",
  "details": {
    "title": ["maximum length is 100"]
  }
}
```
