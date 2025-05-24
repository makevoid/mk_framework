# Project Management System API

A comprehensive project management system built with the MK Framework. This API allows teams to manage projects, tasks, and collaborate effectively.

## Features

- **Project Management**: Create and manage projects with different statuses
- **Task Tracking**: Assign tasks, set priorities, track progress
- **Team Collaboration**: Multiple users with different roles
- **Comments System**: Add comments to tasks for better communication
- **Status Tracking**: Monitor project and task progress
- **Time Tracking**: Estimate and track actual hours spent on tasks

## Data Model

### Users
- Roles: admin, manager, member
- Can own projects and be assigned to tasks
- Password authentication with bcrypt

### Projects
- Status: active, completed, archived, on_hold
- Track start and end dates
- Owned by users
- Contains multiple tasks

### Tasks
- Status: todo, in_progress, review, done
- Priority: low, medium, high, critical
- Can be assigned to users
- Track estimated vs actual hours
- Support due dates and completion tracking

### Comments
- Attached to tasks
- Created by users
- Support threaded discussions

## Setup

1. Install dependencies:
```bash
bundle install
```

2. Run the server:
```bash
bundle exec rackup
```

3. Run tests:
```bash
bundle exec rspec
```

## Architecture

The application follows the MK Framework patterns:

- **Models**: Business logic and data validation
- **Controllers**: Handle requests and data operations
- **Handlers**: Format responses and set HTTP status codes
- **Clean separation**: Each component has a single responsibility

## Key Features Implementation

### Task Assignment System
Tasks can be assigned to team members with a dedicated endpoint that validates both task and user existence.

### Project Statistics
Projects can return detailed statistics about their tasks, including counts by status.

### Overdue Task Detection
The system automatically detects overdue tasks based on due dates and completion status.

### Soft Delete / Archive
Projects can be archived instead of deleted, preserving historical data.

### Time Tracking
Tasks support both estimated and actual hours for better project planning.

## Testing

The application includes comprehensive test coverage for all endpoints. Run tests with:

```bash
bundle exec rspec
```

## Future Enhancements

- Authentication and authorization
- File attachments for tasks
- Task dependencies
- Recurring tasks
- Email notifications
- Activity logs
- Team workload visualization
- Gantt chart data endpoints