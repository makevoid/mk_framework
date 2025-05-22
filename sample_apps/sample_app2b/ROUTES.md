# Building a Next.js + Tailwind CSS Frontend for Todo API

This guide explains how to implement a frontend application using Next.js and Tailwind CSS that interacts with the MK Framework Todo API.

## Setup

### 1. Create Next.js Project

```bash
# Create a new Next.js project
npx create-next-app@latest todo-frontend
cd todo-frontend

# Answer the following questions:
# ✓ Would you like to use TypeScript? Yes
# ✓ Would you like to use ESLint? Yes
# ✓ Would you like to use Tailwind CSS? Yes
# ✓ Would you like to use `src/` directory? Yes
# ✓ Would you like to use App Router? Yes
# ✓ Would you like to customize the default import alias? No
```

### 2. Configure API Connection

Create a utility file to handle API requests:

```bash
mkdir -p src/lib
touch src/lib/api.ts
```

## API Integration

### API Utility Module

Add the following code to `src/lib/api.ts`:

```typescript
// API base URL
const API_URL = 'http://localhost:9292';

// Todo interface
export interface Todo {
  id: number;
  title: string;
  description?: string;
  completed: boolean;
  created_at: string;
  updated_at: string;
}

// API response interfaces
export interface TodoCreatedResponse {
  message: string;
  todo: Todo;
}

export interface TodoUpdatedResponse {
  message: string;
  todo: Todo;
}

export interface TodoDeletedResponse {
  message: string;
  todo: Todo;
}

export interface ApiError {
  error: string;
  details?: Record<string, string[]>;
}

// API methods
export const api = {
  // Get all todos
  async getTodos(): Promise<Todo[]> {
    const response = await fetch(`${API_URL}/todos`);
    
    if (!response.ok) {
      const error = await response.json() as ApiError;
      throw new Error(error.error || 'Failed to fetch todos');
    }
    
    return response.json();
  },
  
  // Get a specific todo
  async getTodo(id: number): Promise<Todo> {
    const response = await fetch(`${API_URL}/todos/${id}`);
    
    if (!response.ok) {
      const error = await response.json() as ApiError;
      throw new Error(error.error || 'Failed to fetch todo');
    }
    
    return response.json();
  },
  
  // Create a new todo
  async createTodo(data: {
    title: string;
    description?: string;
    completed?: boolean;
  }): Promise<TodoCreatedResponse> {
    const response = await fetch(`${API_URL}/todos`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });
    
    if (!response.ok) {
      const error = await response.json() as ApiError;
      throw new Error(error.error || 'Failed to create todo');
    }
    
    return response.json();
  },
  
  // Update a todo
  async updateTodo(id: number, data: {
    title?: string;
    description?: string;
    completed?: boolean;
  }): Promise<TodoUpdatedResponse> {
    const response = await fetch(`${API_URL}/todos/${id}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });
    
    if (!response.ok) {
      const error = await response.json() as ApiError;
      throw new Error(error.error || 'Failed to update todo');
    }
    
    return response.json();
  },
  
  // Delete a todo
  async deleteTodo(id: number): Promise<TodoDeletedResponse> {
    const response = await fetch(`${API_URL}/todos/${id}/delete`, {
      method: 'POST',
    });
    
    if (!response.ok) {
      const error = await response.json() as ApiError;
      throw new Error(error.error || 'Failed to delete todo');
    }
    
    return response.json();
  }
};
```

## Frontend Components

### 1. Todo List Component

Create a component to display all todos:

```tsx
// src/components/TodoList.tsx
'use client';

import { useEffect, useState } from 'react';
import { api, Todo } from '@/lib/api';
import TodoItem from './TodoItem';
import AddTodoForm from './AddTodoForm';

export default function TodoList() {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadTodos();
  }, []);

  async function loadTodos() {
    try {
      setLoading(true);
      const data = await api.getTodos();
      setTodos(data);
      setError(null);
    } catch (err) {
      setError('Failed to load todos');
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  async function handleAddTodo(title: string, description: string) {
    try {
      const response = await api.createTodo({ title, description });
      setTodos([...todos, response.todo]);
    } catch (err) {
      setError('Failed to add todo');
      console.error(err);
    }
  }

  async function handleToggleComplete(id: number, completed: boolean) {
    try {
      await api.updateTodo(id, { completed });
      setTodos(todos.map(todo => 
        todo.id === id ? { ...todo, completed } : todo
      ));
    } catch (err) {
      setError('Failed to update todo');
      console.error(err);
    }
  }

  async function handleDeleteTodo(id: number) {
    try {
      await api.deleteTodo(id);
      setTodos(todos.filter(todo => todo.id !== id));
    } catch (err) {
      setError('Failed to delete todo');
      console.error(err);
    }
  }

  if (loading) {
    return (
      <div className="flex justify-center p-8">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto p-4">
      <h1 className="text-3xl font-bold mb-6 text-center">Todo List</h1>
      
      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
      )}
      
      <AddTodoForm onAddTodo={handleAddTodo} />
      
      <div className="mt-8 space-y-4">
        {todos.length === 0 ? (
          <p className="text-center text-gray-500">No todos yet. Add one above!</p>
        ) : (
          todos.map(todo => (
            <TodoItem 
              key={todo.id} 
              todo={todo} 
              onToggleComplete={handleToggleComplete}
              onDelete={handleDeleteTodo}
            />
          ))
        )}
      </div>
    </div>
  );
}
```

### 2. Todo Item Component

Create a component for individual todos:

```tsx
// src/components/TodoItem.tsx
import { Todo } from '@/lib/api';

interface TodoItemProps {
  todo: Todo;
  onToggleComplete: (id: number, completed: boolean) => void;
  onDelete: (id: number) => void;
}

export default function TodoItem({ todo, onToggleComplete, onDelete }: TodoItemProps) {
  return (
    <div className="bg-white shadow rounded-lg p-4 flex items-start justify-between">
      <div className="flex items-start space-x-3">
        <input
          type="checkbox"
          checked={todo.completed}
          onChange={() => onToggleComplete(todo.id, !todo.completed)}
          className="mt-1 h-5 w-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
        />
        <div>
          <h3 className={`text-lg font-medium ${todo.completed ? 'line-through text-gray-400' : 'text-gray-800'}`}>
            {todo.title}
          </h3>
          {todo.description && (
            <p className={`mt-1 text-sm ${todo.completed ? 'text-gray-400' : 'text-gray-600'}`}>
              {todo.description}
            </p>
          )}
          <p className="text-xs text-gray-400 mt-1">
            Created: {new Date(todo.created_at).toLocaleString()}
          </p>
        </div>
      </div>
      
      <button
        onClick={() => onDelete(todo.id)}
        className="text-red-500 hover:text-red-700 focus:outline-none"
      >
        <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
        </svg>
      </button>
    </div>
  );
}
```

### 3. Add Todo Form Component

Create a form for adding new todos:

```tsx
// src/components/AddTodoForm.tsx
import { useState } from 'react';

interface AddTodoFormProps {
  onAddTodo: (title: string, description: string) => void;
}

export default function AddTodoForm({ onAddTodo }: AddTodoFormProps) {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [error, setError] = useState<string | null>(null);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    
    if (!title.trim()) {
      setError('Title is required');
      return;
    }
    
    if (title.length > 100) {
      setError('Title must be less than 100 characters');
      return;
    }
    
    onAddTodo(title, description);
    setTitle('');
    setDescription('');
    setError(null);
  }

  return (
    <form onSubmit={handleSubmit} className="bg-white shadow rounded-lg p-6">
      <h2 className="text-xl font-semibold mb-4">Add New Todo</h2>
      
      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-2 rounded mb-4 text-sm">
          {error}
        </div>
      )}
      
      <div className="mb-4">
        <label htmlFor="title" className="block text-sm font-medium text-gray-700 mb-1">
          Title <span className="text-red-500">*</span>
        </label>
        <input
          type="text"
          id="title"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-blue-500 focus:border-blue-500"
          placeholder="Enter todo title"
        />
      </div>
      
      <div className="mb-4">
        <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-1">
          Description
        </label>
        <textarea
          id="description"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-blue-500 focus:border-blue-500"
          placeholder="Enter todo description (optional)"
          rows={3}
        />
      </div>
      
      <button
        type="submit"
        className="w-full bg-blue-500 hover:bg-blue-600 text-white font-medium py-2 px-4 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
      >
        Add Todo
      </button>
    </form>
  );
}
```

### 4. Main Page Component

Set up the main page of your application:

```tsx
// src/app/page.tsx
import TodoList from '@/components/TodoList';

export default function Home() {
  return (
    <main className="min-h-screen bg-gray-50 py-8">
      <TodoList />
    </main>
  );
}
```

## CORS Configuration

For the API to accept requests from your Next.js frontend, you'll need to enable CORS on the Ruby backend. Add the following to your `app.rb` file:

```ruby
# Inside the TodoApp class

plugin :cors
route do |r|
  # Set CORS headers
  response['Access-Control-Allow-Origin'] = 'http://localhost:3000'
  response['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
  response['Access-Control-Allow-Headers'] = 'Content-Type'
  
  # Handle OPTIONS requests for CORS preflight
  if r.options
    response.status = 200
    ""
  else
    # Your existing route code here
  end
end
```

## Running the Application

1. Start the Ruby backend:

```bash
# In the sample_app2 directory
bundle exec rackup
```

2. Start the Next.js development server:

```bash
# In the todo-frontend directory
npm run dev
```

3. Open your browser to `http://localhost:3000` to use the application

## Key Frontend Implementation Notes

### API Integration
- **Framework-specific methods**: The API utility adapts to the MK Framework's non-standard HTTP method conventions
- **Error Handling**: Each API call includes proper error handling

### Component Structure
- **TodoList**: Top-level component that fetches and manages todos
- **TodoItem**: Displays individual todos with completion toggle and delete functionality
- **AddTodoForm**: Handles creation of new todos with validation

### Form Validation
- Validates inputs according to API requirements (title presence, max length)
- Provides user feedback for validation errors

### State Management
- Uses React's useState for local state management
- Data fetching with useEffect hook

### Styling
- Uses Tailwind CSS for consistent, responsive design
- Conditional styling based on todo state (completed/incomplete)

## Next Steps

1. **Authentication**: Add user authentication if you expand the API
2. **Edit functionality**: Implement a form to edit existing todos
3. **Filtering and Sorting**: Add UI controls to filter by completion status or sort by date
4. **Pagination**: Implement pagination for large todo lists
5. **Toast Notifications**: Add success/error feedback using a toast notification library
6. **Persistence**: Add local storage backup for offline functionality