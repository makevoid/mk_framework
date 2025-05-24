# E-commerce API

A RESTful e-commerce API built with the MK Framework featuring products, cart management, and checkout functionality.

## Features

- Product catalog with inventory management
- Shopping cart functionality with session-based persistence
- Checkout process with order creation
- Stock validation and management
- RESTful API design

## Installation

```bash
# Clone the repository
git clone <repository-url>
cd ecommerce

# Install dependencies
bundle install

# Start the server
bundle exec rackup
```

The server will start on http://localhost:9292

## API Endpoints

### Products

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/products` | GET | List all active products |
| `/products/:id` | GET | Get a specific product |
| `/products` | POST | Create a new product |
| `/products/:id` | POST | Update a product |
| `/products/:id/delete` | POST | Delete a product |

### Cart

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/cart/:session_id` | GET | Get cart contents |
| `/cart/:session_id/add` | POST | Add item to cart |
| `/cart/:session_id/items/:item_id` | POST | Update cart item quantity |
| `/cart/:session_id/items/:item_id/delete` | POST | Remove item from cart |
| `/cart/:session_id/clear` | POST | Clear entire cart |

### Checkout

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/checkout` | POST | Create order from cart |

## Request/Response Examples

### List Products

```
GET /products?min_price=10&max_price=100
```

Response:
```json
[
  {
    "id": 1,
    "name": "Premium Coffee Beans",
    "description": "Arabica beans from Colombia",
    "price": 24.99,
    "stock": 50,
    "sku": "COF-001",
    "image_url": "https://example.com/coffee.jpg",
    "active": true,
    "created_at": "2024-01-01T10:00:00Z",
    "updated_at": "2024-01-01T10:00:00Z"
  }
]
```

### Add to Cart

```
POST /cart/abc123/add
```

Request:
```json
{
  "product_id": 1,
  "quantity": 2
}
```

Response:
```json
{
  "message": "Item added to cart",
  "cart": {
    "id": 1,
    "session_id": "abc123",
    "total": 49.98,
    "item_count": 2,
    "items": [
      {
        "id": 1,
        "product": { ... },
        "quantity": 2,
        "price": 24.99,
        "subtotal": 49.98
      }
    ]
  }
}
```

### Checkout

```
POST /checkout
```

Request:
```json
{
  "session_id": "abc123",
  "customer_email": "john@example.com",
  "customer_name": "John Doe",
  "shipping_address": "123 Main St, City, Country",
  "payment_method": "credit_card"
}
```

Response:
```json
{
  "message": "Order placed successfully",
  "order": {
    "id": 1,
    "order_number": "ORD-20240101-A1B2C3D4",
    "total": 49.98,
    "status": "pending",
    "customer_email": "john@example.com",
    "customer_name": "John Doe",
    "shipping_address": "123 Main St, City, Country",
    "created_at": "2024-01-01T15:30:00Z"
  }
}
```

## Testing

Run the test suite:

```bash
bundle exec rspec
```

## Architecture

- **Models**: Define data schema, validations, and business logic
- **Controllers**: Handle request processing and data operations
- **Handlers**: Format responses and set HTTP status codes
- **Database**: SQLite with Sequel ORM

## Notes

- Cart is session-based (no user authentication required)
- Stock is validated during cart operations and checkout
- Orders are created in a transaction to ensure data consistency
- Products can be soft-deleted by setting `active` to false
- The route names are always plural, so if you need to implement for example a checkout route do not use `/checkout` in the paths, use `/checkouts`, so the create of `/checkouts` will be `POST /checkouts` - This is typical in rails-like frameworks that use standard CRUD resources.
