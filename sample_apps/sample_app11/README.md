# E-commerce Backend API

A comprehensive e-commerce backend API built with the MK Framework, featuring products, categories, shopping carts, and orders.

## Overview

This application demonstrates a real-world SQL-based backend with proper entity relationships:

- **Products** with categories, inventory management, and pricing
- **Categories** for product organization
- **Shopping Carts** for user session management
- **Order Management** with line items and status tracking
- **Users** for authentication and order history

## Features

- Complete product catalog management
- Category-based product organization
- Shopping cart functionality
- Order processing and tracking
- Inventory management
- User management
- RESTful API design with proper HTTP status codes
- Input validation and error handling
- SQLite database with proper relationships

## Installation

```bash
# Install dependencies
bundle install

# Start the server
bundle exec rackup
```

The server will start on http://localhost:9292

## Database Schema

The application uses SQLite with the following tables:

- **users**: User accounts with authentication
- **categories**: Product categories
- **products**: Product catalog with inventory
- **cart_items**: Shopping cart contents
- **orders**: Order information
- **order_items**: Order line items

## API Endpoints

### Products
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/products` | GET | List all products (with filters) |
| `/products/:id` | GET | Get a specific product |
| `/products` | POST | Create a new product |
| `/products/:id` | POST | Update a product |
| `/products/:id/delete` | POST | Delete a product |

### Categories
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/categories` | GET | List all categories |
| `/categories/:id` | GET | Get a specific category |
| `/categories` | POST | Create a new category |
| `/categories/:id` | POST | Update a category |
| `/categories/:id/delete` | POST | Delete a category |

### Users
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/users` | GET | List all users |
| `/users/:id` | GET | Get a specific user |
| `/users` | POST | Create a new user |
| `/users/:id` | POST | Update a user |
| `/users/:id/delete` | POST | Delete a user |

### Shopping Cart
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/users/:user_id/carts` | GET | Get user's cart contents |
| `/users/:user_id/carts` | POST | Add item to cart |
| `/users/:user_id/carts/:id` | POST | Update cart item |
| `/users/:user_id/carts/:id/delete` | POST | Remove item from cart |

### Orders
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/orders` | GET | List all orders |
| `/orders/:id` | GET | Get a specific order |
| `/orders` | POST | Create order from cart |
| `/orders/:id` | POST | Update order status |
| `/orders/:id/delete` | POST | Cancel order |

## API Usage Examples

### 1. Create a new product

```bash
curl -X POST http://localhost:9292/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Premium Headphones",
    "description": "High-quality wireless headphones",
    "price": 199.99,
    "stock_quantity": 50,
    "sku": "HP-PREM-001",
    "category_id": 1
  }'
```

### 2. Get products with filters

```bash
# Get all products
curl http://localhost:9292/products

# Search for products
curl http://localhost:9292/products?search=headphones

# Filter by category
curl http://localhost:9292/products?category_id=1

# Only in-stock products
curl http://localhost:9292/products?in_stock=true
```

### 3. Add items to cart

```bash
curl -X POST http://localhost:9292/users/1/carts \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": 1,
    "quantity": 2
  }'
```

### 4. View cart contents

```bash
curl http://localhost:9292/users/1/carts
```

### 5. Create an order

```bash
curl -X POST http://localhost:9292/orders \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "shipping_address": "123 Main St, City, State 12345",
    "notes": "Please deliver in the afternoon"
  }'
```

### 6. Get order details

```bash
curl http://localhost:9292/orders/1
```

## Architecture

This application follows a clean separation of concerns:

1. **Models** (`models/`): Define data schema and validation rules using Sequel::Model
2. **Controllers** (`routes/*/controllers/`): Handle business logic and data operations
3. **Handlers** (`routes/*/handlers/`): Format responses and set HTTP status codes
4. **Application** (`app.rb`): Configure database and routes

## Testing

Run the test suite with:

```bash
bundle exec rspec
```

Run a specific test file:

```bash
bundle exec rspec spec/request/ecommerce_spec.rb
```

## Key Features

1. **Complete Product Management**: CRUD operations with category relationships
2. **Shopping Cart**: Session-based cart management with stock validation
3. **Order Processing**: Complete order workflow with inventory updates
4. **Data Integrity**: Proper foreign keys and transaction handling
5. **Input Validation**: Comprehensive validation on all models
6. **Error Handling**: Proper HTTP status codes and error messages
7. **Business Logic**: Stock management, cart totals, order status workflow
8. **API Documentation**: Clear endpoint documentation with examples

This e-commerce API demonstrates real-world patterns including:
- Complex entity relationships
- Transaction handling for data consistency
- Business rule enforcement
- Proper error handling and validation
- RESTful API design with nested resources
- Stock management and inventory tracking

The application can be extended with features like:
- User authentication and authorization
- Payment processing integration
- Product reviews and ratings
- Discounts and promotions
- Admin dashboard APIs
- Order tracking and notifications

## Framework Notes

The MK Framework has some unique conventions:

- DELETE operations use POST to `/:resource/:id/delete` instead of DELETE method
- UPDATE operations use POST to `/:resource/:id` instead of PUT/PATCH
- Controllers handle data operations, handlers manage response formatting
- Nested resources are supported (e.g., `/users/:user_id/carts`)