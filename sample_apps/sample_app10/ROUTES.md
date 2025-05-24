# API Routes Documentation

## Base URL
```
http://localhost:9292
```

## Authentication
Currently, the API doesn't implement authentication. In a production environment, you would add JWT or session-based authentication.

## Available Routes

### Projects

#### List Projects
- **GET** `/projects`
- **Query Parameters**:  
  - `status`: Filter by status (active, completed, archived, on_hold)
  - `owner_id`: Filter by owner
  - `include_stats`: Include task statistics (true/false)
- **Response**: List of projects with optional statistics

#### Get Project
- **GET** `/projects/:id`
- **Response**: Single project with details

#### Create Project
- **POST** `/projects`
- **Body**:
  ```json
  {
    "name": "New Project",
    "description": "Project description",
    "status": "active",
    "start_date": "2024-01-01",
    "end_date": "2024-12-31",
    "owner_id": 1
  }
  ```

#### Update Project
- **POST** `/projects/:id`
- **Body**: Any fields to update

#### Delete Project
- **POST** `/projects/:id/delete`

#### Archive Project
- **POST** `/projects/:id/archive`

### Tasks

#### List Tasks
- **GET** `/tasks`
- **Query Parameters**:
  - `project_id`: Filter by project
  - `assigned_to_id`: Filter by assignee
  - `status`: Filter by status
  - `priority`: Filter by priority
  - `include_associations`: Include related data

#### Get Task
- **GET** `/tasks/:id`

#### Create Task
- **POST** `/tasks`
- **Body**:
  ```json
  {
    "title": "Implement feature X",
    "description": "Detailed description",
    "project_id": 1,
    "assigned_to_id": 2,
    "created_by_id": 1,
    "priority": "high",
    "due_date": "2024-02-01",
    "estimated_hours": 8
  }
  ```

#### Update Task
- **POST** `/tasks/:id`

#### Delete Task
- **POST** `/tasks/:id/delete`

#### Assign Task
- **POST** `/tasks/:id/assign`
- **Body**:
  ```json
  {
    "user_id": 3
  }
  ```

### Users

#### List Users
- **GET** `/users`
- **Query Parameters**:
  - `role`: Filter by role
  - `active`: Filter by active status

#### Get User
- **GET** `/users/:id`

#### Create User
- **POST** `/users`
- **Body**:
  ```json
  {
    "name": "John Doe",
    "email": "john@example.com",
    "password": "secure_password",
    "role": "member"
  }
  ```

#### Update User
- **POST** `/users/:id`

#### Delete User
- **POST** `/users/:id/delete`

### Comments

#### List Comments for Task
- **GET** `/comments?task_id=:task_id`

#### Create Comment
- **POST** `/comments`
- **Body**:
  ```json
  {
    "content": "This is a comment",
    "task_id": 1,
    "user_id": 1
  }
  ```

#### Delete Comment
- **POST** `/comments/:id/delete`

## Example Usage

### Create a new project with tasks
```bash
# 1. Create a project
curl -X POST http://localhost:9292/projects \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Website Redesign",
    "description": "Complete overhaul of company website",
    "owner_id": 1,
    "start_date": "2024-01-15",
    "end_date": "2024-03-30"
  }'

# 2. Create tasks for the project
curl -X POST http://localhost:9292/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Design new homepage",
    "project_id": 1,
    "assigned_to_id": 2,
    "created_by_id": 1,
    "priority": "high",
    "due_date": "2024-02-01"
  }'

# 3. Add a comment to the task
curl -X POST http://localhost:9292/comments \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Initial wireframes are ready for review",
    "task_id": 1,
    "user_id": 2
  }'
```

### Get project with statistics
```bash
curl http://localhost:9292/projects/1?include_stats=true
```

### Assign a task to a different user
```bash
curl -X POST http://localhost:9292/tasks/1/assign \
  -H "Content-Type: application/json" \
  -d '{"user_id": 3}'
```