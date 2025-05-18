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

## Implementing a Next.js Frontend

Here's a guide to implementing a calendar application using Next.js that interacts with this API.

### Project Setup

1. Create a Next.js project:
```bash
npx create-next-app calendar-frontend
cd calendar-frontend
```

2. Install dependencies:
```bash
npm install axios date-fns react-big-calendar
```

### API Service

Create a service to interact with the API:

```javascript
// services/api.js
import axios from 'axios';

const API_URL = 'http://localhost:9292';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const eventService = {
  // Get all events
  getEvents: async () => {
    const response = await api.get('/events');
    return response.data;
  },

  // Get a single event
  getEvent: async (id) => {
    const response = await api.get(`/events/${id}`);
    return response.data;
  },

  // Create a new event
  createEvent: async (eventData) => {
    const response = await api.post('/events', eventData);
    return response.data;
  },

  // Update an event
  updateEvent: async (id, eventData) => {
    const response = await api.post(`/events/${id}`, eventData);
    return response.data;
  },

  // Delete an event
  deleteEvent: async (id) => {
    const response = await api.post(`/events/${id}/delete`);
    return response.data;
  },
};
```

### Calendar Component

Create a calendar component using react-big-calendar:

```jsx
// components/Calendar.jsx
import { useState, useEffect } from 'react';
import { Calendar, momentLocalizer } from 'react-big-calendar';
import moment from 'moment';
import 'react-big-calendar/lib/css/react-big-calendar.css';
import { eventService } from '../services/api';

// Setup the localizer
const localizer = momentLocalizer(moment);

export default function CalendarView() {
  const [events, setEvents] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchEvents();
  }, []);

  const fetchEvents = async () => {
    try {
      setLoading(true);
      const data = await eventService.getEvents();

      // Transform API data to calendar events format
      const formattedEvents = data.map(event => ({
        id: event.id,
        title: event.title,
        start: new Date(event.start_time),
        end: new Date(event.end_time),
        allDay: event.all_day,
        resource: event, // Store the complete event object
      }));

      setEvents(formattedEvents);
    } catch (error) {
      console.error('Error fetching events:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSelectEvent = (event) => {
    // Handle click on an event
    console.log('Selected event:', event);
    // Navigate to event details or open a modal
  };

  const handleSelectSlot = ({ start, end }) => {
    // Handle creating a new event
    console.log('Selected slot:', { start, end });
    // Open a modal for creating a new event
  };

  if (loading) {
    return <div>Loading calendar...</div>;
  }

  return (
    <div style={{ height: '700px' }}>
      <Calendar
        localizer={localizer}
        events={events}
        startAccessor="start"
        endAccessor="end"
        onSelectEvent={handleSelectEvent}
        onSelectSlot={handleSelectSlot}
        selectable
        views={['month', 'week', 'day', 'agenda']}
      />
    </div>
  );
}
```

### Event Form Component

Create a form for adding/editing events:

```jsx
// components/EventForm.jsx
import { useState, useEffect } from 'react';
import { eventService } from '../services/api';

export default function EventForm({ eventId = null, onSuccess }) {
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    start_time: '',
    end_time: '',
    location: '',
    all_day: false,
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (eventId) {
      fetchEvent(eventId);
    }
  }, [eventId]);

  const fetchEvent = async (id) => {
    try {
      setLoading(true);
      const event = await eventService.getEvent(id);
      setFormData({
        title: event.title,
        description: event.description || '',
        start_time: event.start_time ? new Date(event.start_time).toISOString().slice(0, 16) : '',
        end_time: event.end_time ? new Date(event.end_time).toISOString().slice(0, 16) : '',
        location: event.location || '',
        all_day: event.all_day || false,
      });
    } catch (error) {
      console.error('Error fetching event:', error);
      setError('Failed to load event');
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value,
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      setLoading(true);
      setError(null);

      // Format dates for API
      const apiData = {
        ...formData,
        start_time: new Date(formData.start_time).toISOString(),
        end_time: formData.end_time ? new Date(formData.end_time).toISOString() : null,
      };

      if (eventId) {
        await eventService.updateEvent(eventId, apiData);
      } else {
        await eventService.createEvent(apiData);
      }

      if (onSuccess) onSuccess();

    } catch (error) {
      console.error('Error saving event:', error);
      setError('Failed to save event. Please check your input and try again.');
    } finally {
      setLoading(false);
    }
  };

  if (loading && eventId) {
    return <div>Loading event...</div>;
  }

  return (
    <form onSubmit={handleSubmit}>
      {error && (
        <div className="error">{error}</div>
      )}

      <div>
        <label htmlFor="title">Title *</label>
        <input
          id="title"
          name="title"
          type="text"
          value={formData.title}
          onChange={handleChange}
          required
          maxLength={100}
        />
      </div>

      <div>
        <label htmlFor="description">Description</label>
        <textarea
          id="description"
          name="description"
          value={formData.description}
          onChange={handleChange}
          maxLength={500}
        />
      </div>

      <div>
        <label htmlFor="start_time">Start Time *</label>
        <input
          id="start_time"
          name="start_time"
          type="datetime-local"
          value={formData.start_time}
          onChange={handleChange}
          required
        />
      </div>

      <div>
        <label htmlFor="end_time">End Time</label>
        <input
          id="end_time"
          name="end_time"
          type="datetime-local"
          value={formData.end_time}
          onChange={handleChange}
        />
      </div>

      <div>
        <label htmlFor="location">Location</label>
        <input
          id="location"
          name="location"
          type="text"
          value={formData.location}
          onChange={handleChange}
        />
      </div>

      <div>
        <label>
          <input
            name="all_day"
            type="checkbox"
            checked={formData.all_day}
            onChange={handleChange}
          />
          All-day event
        </label>
      </div>

      <button type="submit" disabled={loading}>
        {loading ? 'Saving...' : eventId ? 'Update Event' : 'Create Event'}
      </button>
    </form>
  );
}
```

### Pages

Create the Next.js pages:

```jsx
// pages/index.js
import CalendarView from '../components/Calendar';

export default function Home() {
  return (
    <div>
      <h1>Calendar Events</h1>
      <CalendarView />
    </div>
  );
}
```

```jsx
// pages/events/new.js
import { useRouter } from 'next/router';
import EventForm from '../../components/EventForm';

export default function NewEvent() {
  const router = useRouter();

  const handleSuccess = () => {
    router.push('/');
  };

  return (
    <div>
      <h1>Create New Event</h1>
      <EventForm onSuccess={handleSuccess} />
    </div>
  );
}
```

```jsx
// pages/events/[id]/edit.js
import { useRouter } from 'next/router';
import EventForm from '../../../components/EventForm';

export default function EditEvent() {
  const router = useRouter();
  const { id } = router.query;

  const handleSuccess = () => {
    router.push('/');
  };

  return (
    <div>
      <h1>Edit Event</h1>
      {id && <EventForm eventId={id} onSuccess={handleSuccess} />}
    </div>
  );
}
```

```jsx
// pages/events/[id]/index.js
import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';
import Link from 'next/link';
import { eventService } from '../../../services/api';

export default function EventDetails() {
  const router = useRouter();
  const { id } = router.query;
  const [event, setEvent] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (id) {
      fetchEvent(id);
    }
  }, [id]);

  const fetchEvent = async (eventId) => {
    try {
      setLoading(true);
      const data = await eventService.getEvent(eventId);
      setEvent(data);
    } catch (error) {
      console.error('Error fetching event:', error);
      setError('Failed to load event');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async () => {
    if (window.confirm('Are you sure you want to delete this event?')) {
      try {
        await eventService.deleteEvent(id);
        router.push('/');
      } catch (error) {
        console.error('Error deleting event:', error);
        alert('Failed to delete event');
      }
    }
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>{error}</div>;
  }

  if (!event) {
    return <div>Event not found</div>;
  }

  return (
    <div>
      <h1>{event.title}</h1>

      <div>
        <strong>When:</strong>
        {event.all_day ? (
          <span>All day on {new Date(event.start_time).toLocaleDateString()}</span>
        ) : (
          <span>
            {new Date(event.start_time).toLocaleString()} -
            {event.end_time ? new Date(event.end_time).toLocaleString() : 'N/A'}
          </span>
        )}
      </div>

      {event.location && (
        <div>
          <strong>Where:</strong> {event.location}
        </div>
      )}

      {event.description && (
        <div>
          <strong>Description:</strong>
          <p>{event.description}</p>
        </div>
      )}

      <div>
        <Link href={`/events/${id}/edit`}>
          <a>Edit Event</a>
        </Link>
        {' | '}
        <button onClick={handleDelete}>Delete Event</button>
        {' | '}
        <Link href="/">
          <a>Back to Calendar</a>
        </Link>
      </div>
    </div>
  );
}
```

### Styling and Refinements

Add appropriate styling using CSS modules or a UI framework like Tailwind CSS for a polished user experience. You can enhance the application with:

1. Modal dialogs for creating/editing events
2. Date range filtering for the calendar
3. Color-coding for different event types
4. Drag and drop for event rescheduling
5. Recurring events support
6. Mobile-responsive design

## CORS Configuration

For the frontend to successfully communicate with the backend, ensure CORS is properly configured on the Ruby backend. You may need to add appropriate CORS headers to your responses.

## Deployment

When deploying:

1. Configure the `API_URL` in `services/api.js` to point to your production API endpoint
2. Build the Next.js application with `npm run build`
3. Deploy the static files to your hosting provider

This documentation provides a starting point for building a modern calendar application using the API endpoints provided by the MK Framework backend.
