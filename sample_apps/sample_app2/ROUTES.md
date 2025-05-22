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

---

# Frontend Implementation Guide

## Next.js + Tailwind CSS Todo Application

This guide outlines how to build a frontend for the Todo API using Next.js and Tailwind CSS.

### Core Functionality

Your frontend application should implement the following features:
1. Display a list of todos
2. Show detailed view of a single todo
3. Create new todos
4. Edit existing todos
5. Delete todos
6. Mark todos as completed/uncompleted

### Project Setup

1. Create a new Next.js project with Tailwind CSS:
```bash
npx create-next-app@latest todo-frontend --typescript --tailwind
cd todo-frontend
```

2. Create an API service for interacting with the Todo API:

```typescript
// services/todoApi.ts
import axios from 'axios';

const API_URL = 'http://localhost:9292'; // Replace with your API URL

export interface Todo {
  id: number;
  title: string;
  description: string | null;
  completed: boolean;
  created_at: string;
  updated_at: string;
}

export interface TodosResponse {
  todos: Todo[];
  custom_field: string;
}

export const todoApi = {
  // Get all todos
  async getTodos(): Promise<TodosResponse> {
    const response = await axios.get(`${API_URL}/todos`);
    return response.data;
  },

  // Get a specific todo
  async getTodo(id: number): Promise<Todo> {
    const response = await axios.get(`${API_URL}/todos/${id}`);
    return response.data;
  },

  // Create a new todo
  async createTodo(todo: { title: string; description?: string }): Promise<{ message: string; todo: Todo }> {
    const response = await axios.post(`${API_URL}/todos`, todo);
    return response.data;
  },

  // Update a todo
  async updateTodo(id: number, updates: { title?: string; completed?: boolean }): Promise<{ message: string; todo: Todo }> {
    const response = await axios.post(`${API_URL}/todos/${id}`, updates);
    return response.data;
  },

  // Delete a todo
  async deleteTodo(id: number): Promise<{ message: string; todo: Todo }> {
    const response = await axios.post(`${API_URL}/todos/${id}/delete`);
    return response.data;
  }
};
```

### Implementation Examples

#### 1. Todos List Page (app/page.tsx)

```tsx
'use client';
import { useEffect, useState } from 'react';
import Link from 'next/link';
import { todoApi, Todo } from '@/services/todoApi';

export default function TodosPage() {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchTodos = async () => {
      try {
        const response = await todoApi.getTodos();
        setTodos(response.todos);
      } catch (error) {
        console.error('Failed to fetch todos:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchTodos();
  }, []);

  const toggleCompleted = async (id: number, completed: boolean) => {
    try {
      const response = await todoApi.updateTodo(id, { completed: !completed });
      setTodos(todos.map(todo => 
        todo.id === id ? response.todo : todo
      ));
    } catch (error) {
      console.error('Failed to update todo:', error);
    }
  };

  const deleteTodo = async (id: number) => {
    try {
      await todoApi.deleteTodo(id);
      setTodos(todos.filter(todo => todo.id !== id));
    } catch (error) {
      console.error('Failed to delete todo:', error);
    }
  };

  if (loading) {
    return <div className="flex justify-center p-8">Loading todos...</div>;
  }

  return (
    <div className="container mx-auto p-4">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Todos</h1>
        <Link 
          href="/todos/new" 
          className="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded"
        >
          New Todo
        </Link>
      </div>

      <div className="space-y-4">
        {todos.length === 0 ? (
          <p className="text-gray-500 text-center py-4">No todos found. Create one!</p>
        ) : (
          todos.map(todo => (
            <div 
              key={todo.id}
              className="border rounded-lg p-4 flex items-center justify-between hover:shadow-md transition"
            >
              <div className="flex items-center space-x-3">
                <input
                  type="checkbox"
                  checked={todo.completed}
                  onChange={() => toggleCompleted(todo.id, todo.completed)}
                  className="h-5 w-5 text-blue-500"
                />
                <div className={todo.completed ? "line-through text-gray-500" : ""}>
                  <Link href={`/todos/${todo.id}`} className="font-medium hover:text-blue-500">
                    {todo.title}
                  </Link>
                  {todo.description && (
                    <p className="text-sm text-gray-600">{todo.description}</p>
                  )}
                </div>
              </div>
              
              <div className="flex space-x-2">
                <Link 
                  href={`/todos/${todo.id}/edit`}
                  className="text-gray-600 hover:text-blue-500"
                >
                  Edit
                </Link>
                <button 
                  onClick={() => deleteTodo(todo.id)}
                  className="text-gray-600 hover:text-red-500"
                >
                  Delete
                </button>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
```

#### 2. Create Todo Form (app/todos/new/page.tsx)

```tsx
'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { todoApi } from '@/services/todoApi';

export default function NewTodoPage() {
  const router = useRouter();
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [error, setError] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!title.trim()) {
      setError('Title is required');
      return;
    }
    
    setIsSubmitting(true);
    setError('');
    
    try {
      await todoApi.createTodo({ 
        title, 
        description: description.trim() || undefined 
      });
      router.push('/');
      router.refresh();
    } catch (error: any) {
      setError(error.response?.data?.error || 'Failed to create todo');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="container mx-auto p-4 max-w-md">
      <h1 className="text-2xl font-bold mb-6">Create New Todo</h1>
      
      {error && (
        <div className="bg-red-50 text-red-500 p-3 rounded mb-4">
          {error}
        </div>
      )}
      
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label htmlFor="title" className="block text-sm font-medium mb-1">
            Title <span className="text-red-500">*</span>
          </label>
          <input
            id="title"
            type="text"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            className="w-full border rounded-md p-2"
            placeholder="Enter todo title"
          />
        </div>
        
        <div>
          <label htmlFor="description" className="block text-sm font-medium mb-1">
            Description (optional)
          </label>
          <textarea
            id="description"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            className="w-full border rounded-md p-2"
            rows={3}
            placeholder="Enter description"
          />
        </div>
        
        <div className="flex space-x-3 pt-2">
          <button
            type="button"
            onClick={() => router.back()}
            className="px-4 py-2 border rounded-md hover:bg-gray-50"
          >
            Cancel
          </button>
          <button
            type="submit"
            disabled={isSubmitting}
            className="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-md disabled:opacity-50"
          >
            {isSubmitting ? 'Creating...' : 'Create Todo'}
          </button>
        </div>
      </form>
    </div>
  );
}
```

#### 3. Todo Details Component (app/todos/[id]/page.tsx)

```tsx
'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { todoApi, Todo } from '@/services/todoApi';

export default function TodoDetailsPage({ params }: { params: { id: string } }) {
  const router = useRouter();
  const [todo, setTodo] = useState<Todo | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchTodo = async () => {
      try {
        const data = await todoApi.getTodo(parseInt(params.id));
        setTodo(data);
      } catch (error) {
        setError('Failed to load todo. It might have been deleted.');
      } finally {
        setLoading(false);
      }
    };

    fetchTodo();
  }, [params.id]);

  const handleDelete = async () => {
    if (!todo) return;
    
    if (confirm('Are you sure you want to delete this todo?')) {
      try {
        await todoApi.deleteTodo(todo.id);
        router.push('/');
      } catch (error) {
        setError('Failed to delete todo');
      }
    }
  };

  if (loading) {
    return <div className="flex justify-center p-8">Loading todo...</div>;
  }

  if (error) {
    return (
      <div className="container mx-auto p-4 max-w-md">
        <div className="bg-red-50 text-red-500 p-4 rounded-md">
          {error}
        </div>
        <div className="mt-4">
          <Link href="/" className="text-blue-500 hover:underline">
            ← Back to todos
          </Link>
        </div>
      </div>
    );
  }

  if (!todo) {
    return <div>Todo not found</div>;
  }

  return (
    <div className="container mx-auto p-4 max-w-md">
      <div className="bg-white rounded-lg shadow-md p-6">
        <div className="flex justify-between items-start mb-4">
          <h1 className="text-2xl font-bold">
            {todo.title}
          </h1>
          <span className={`px-2 py-1 rounded-full text-xs ${
            todo.completed 
              ? 'bg-green-100 text-green-800' 
              : 'bg-yellow-100 text-yellow-800'
          }`}>
            {todo.completed ? 'Completed' : 'Pending'}
          </span>
        </div>
        
        {todo.description && (
          <div className="mb-4">
            <h2 className="text-sm font-medium text-gray-500 mb-1">Description</h2>
            <p className="text-gray-700">{todo.description}</p>
          </div>
        )}
        
        <div className="grid grid-cols-2 gap-4 mb-6">
          <div>
            <h2 className="text-sm font-medium text-gray-500 mb-1">Created</h2>
            <p className="text-gray-700">
              {new Date(todo.created_at).toLocaleDateString()}
            </p>
          </div>
          <div>
            <h2 className="text-sm font-medium text-gray-500 mb-1">Last Updated</h2>
            <p className="text-gray-700">
              {new Date(todo.updated_at).toLocaleDateString()}
            </p>
          </div>
        </div>
        
        <div className="flex space-x-3 pt-2 border-t">
          <Link 
            href="/"
            className="text-gray-600 hover:text-gray-800 py-2"
          >
            ← Back
          </Link>
          <div className="flex-grow"></div>
          <Link
            href={`/todos/${todo.id}/edit`}
            className="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-md"
          >
            Edit
          </Link>
          <button
            onClick={handleDelete}
            className="bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded-md"
          >
            Delete
          </button>
        </div>
      </div>
    </div>
  );
}
```

### Key Implementation Considerations

1. **API Communication**:
   - Use a centralized API service
   - Handle error states properly
   - Include loading states for better UX

2. **State Management**:
   - For a small app, React's useState and useEffect are sufficient
   - For larger apps, consider React Query or Redux

3. **Responsive Design**:
   - Use Tailwind's responsive classes (sm:, md:, lg:, etc.) to ensure the UI works on all devices

4. **Accessibility**:
   - Include proper ARIA attributes
   - Ensure keyboard navigation works
   - Use semantic HTML elements

5. **Form Handling**:
   - Validate inputs before submission
   - Provide clear error messages
   - Consider using a form library for complex forms (React Hook Form, Formik)

6. **Navigation**:
   - Use Next.js navigation for optimal performance
   - Implement proper loading states during navigation

7. **Testing**:
   - Write unit tests for components using Jest and React Testing Library
   - Consider E2E tests with Cypress for critical flows

By following this implementation guide, you'll create a clean, responsive, and user-friendly Todo application that effectively uses the provided API.