# Weather API

A RESTful API for retrieving weather forecasts built with the MK Framework, a lightweight Ruby web framework based on Roda.

## Overview

This application demonstrates a clean separation of concerns with a RESTful architecture:

- **Controllers**: Handle data retrieval and business logic
- **Handlers**: Format responses and set HTTP status codes
- **Models**: Define data structure and validation rules

## Features

- Retrieve hourly weather forecast for any location
- Cache weather data with automatic 1-hour expiration
- List all previously requested locations
- OpenWeatherMap API integration
- JSON response formatting
- SQLite database storage for caching

## Prerequisites

You need an OpenWeatherMap API key stored in a file at `~/.openweathermaps_api_key`.

## Installation

```bash
# Clone the repository
git clone <repository-url>
cd sample_app6

# Install dependencies
bundle install

# Start the server
bundle exec rackup
```

The server will start on http://localhost:9292

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/weather` | GET | List all cached locations |
| `/weather/:location` | GET | Get weather forecast for a location |

### Request/Response Examples

#### List all cached locations

```
GET /weather
```

Response:
```json
[
  {
    "location": "London",
    "fetched_at": "2023-01-01T12:00:00Z",
    "cache_expires_at": "2023-01-01T13:00:00Z",
    "is_cached": true
  },
  {
    "location": "New York",
    "fetched_at": "2023-01-02T10:00:00Z",
    "cache_expires_at": "2023-01-02T11:00:00Z",
    "is_cached": false
  }
]
```

#### Get a specific location's weather forecast

```
GET /weather/London
```

Response:
```json
{
  "location": "London",
  "hourly_forecast": [
    {
      "time": "2023-01-01T12:00:00Z",
      "temperature": 15.2,
      "feels_like": 14.8,
      "humidity": 76,
      "weather": {
        "main": "Clear",
        "description": "clear sky",
        "icon": "01d"
      },
      "wind": {
        "speed": 2.68,
        "direction": 167
      }
    },
    ...
  ],
  "fetched_at": "2023-01-01T12:00:00Z",
  "cache_expires_at": "2023-01-01T13:00:00Z"
}
```

## Architecture

The application follows a structured architecture:

1. **Models** (`models/weather.rb`): Define the data schema and validation rules
2. **Controllers** (`routes/weather/controllers/`): Handle business logic and data operations
3. **Handlers** (`routes/weather/handlers/`): Format responses and set HTTP status codes
4. **Application** (`app.rb`): Configure the database and set up the application

## Caching

Weather data is cached in the database with the following rules:
- Each location has its own cache entry
- Cache expires after 1 hour
- If the cache is valid, the API returns cached data
- If the cache is expired, new data is fetched from OpenWeatherMap

## Testing

Run the test suite with:

```bash
bundle exec rspec
```

## Framework Notes

The MK Framework has some unique conventions:

- Controllers handle data operations, handlers manage response formatting
- RESTful routes map to controller/handler pairs