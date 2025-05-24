# frozen_string_literal: true

require 'spec_helper'

describe "E-commerce API" do
  before do
    # Clean up all data before each test
    CartItem.dataset.delete
    Order.dataset.delete
    OrderItem.dataset.delete
    User.dataset.delete
    Product.dataset.delete
    Category.dataset.delete
  end

  describe "Categories" do
    describe "GET /categories" do
      before do
        @category1 = Category.create(name: "Electronics", description: "Electronic devices")
        @category2 = Category.create(name: "Books", description: "Books and magazines")
      end

      it "returns all categories" do
        get '/categories'

        expect(last_response.status).to eq 200
        categories = resp[:categories]
        expect(categories.length).to eq 2
        expect(categories[0][:name]).to eq "Electronics"
        expect(categories[1][:name]).to eq "Books"
      end
    end

    describe "POST /categories" do
      it "creates a new category" do
        post '/categories', {
          name: "Clothing",
          description: "Clothing and accessories"
        }

        expect(last_response.status).to eq 201
        expect(resp[:category][:name]).to eq "Clothing"
        expect(resp[:message]).to eq "Category created successfully"
      end
    end
  end

  describe "Products" do
    before do
      @category = Category.create(name: "Electronics")
    end

    describe "GET /products" do
      before do
        @product1 = Product.create(
          name: "Laptop",
          price: 999.99,
          stock_quantity: 10,
          category_id: @category.id
        )
        @product2 = Product.create(
          name: "Mouse",
          price: 29.99,
          stock_quantity: 50,
          category_id: @category.id
        )
      end

      it "returns all products" do
        get '/products'

        expect(last_response.status).to eq 200
        products = resp[:products]
        expect(products.length).to eq 2
        expect(products[0][:name]).to eq "Laptop"
        expect(products[0][:formatted_price]).to eq "$999.99"
        expect(products[1][:name]).to eq "Mouse"
      end

      it "filters products by search term" do
        get '/products?search=laptop'

        expect(last_response.status).to eq 200
        products = resp[:products]
        expect(products.length).to eq 1
        expect(products[0][:name]).to eq "Laptop"
      end
    end

    describe "POST /products" do
      it "creates a new product" do
        post '/products', {
          name: "Keyboard",
          price: 79.99,
          stock_quantity: 25,
          category_id: @category.id,
          sku: "KB-001"
        }

        expect(last_response.status).to eq 201
        expect(resp[:product][:name]).to eq "Keyboard"
        expect(resp[:product][:sku]).to eq "KB-001"
        expect(resp[:message]).to eq "Product created successfully"
      end
    end
  end

  describe "Users" do
    describe "POST /users" do
      it "creates a new user" do
        post '/users', {
          email: "test@example.com",
          password_hash: "hashed_password",
          first_name: "John",
          last_name: "Doe"
        }

        expect(last_response.status).to eq 201
        expect(resp[:user][:email]).to eq "test@example.com"
        expect(resp[:user][:full_name]).to eq "John Doe"
        expect(resp[:user]).not_to have_key(:password_hash)
      end
    end

    describe "GET /users/:id" do
      before do
        @user = User.create(
          email: "test@example.com",
          password_hash: "hashed_password",
          first_name: "Jane",
          last_name: "Smith"
        )
      end

      it "returns the user" do
        get "/users/#{@user.id}"

        expect(last_response.status).to eq 200
        expect(resp[:user][:email]).to eq "test@example.com"
        expect(resp[:user][:full_name]).to eq "Jane Smith"
        expect(resp[:user]).not_to have_key(:password_hash)
      end
    end
  end

  describe "Shopping Cart" do
    before do
      @user = User.create(
        email: "test@example.com",
        password_hash: "hashed_password",
        first_name: "John",
        last_name: "Doe"
      )
      @category = Category.create(name: "Electronics")
      @product = Product.create(
        name: "Laptop",
        price: 999.99,
        stock_quantity: 10,
        category_id: @category.id
      )
    end

    describe "POST /users/:user_id/carts" do
      it "adds item to cart" do
        post "/users/#{@user.id}/carts", {
          product_id: @product.id,
          quantity: 2
        }

        expect(last_response.status).to eq 201
        expect(resp[:cart_item][:quantity]).to eq 2
        expect(resp[:message]).to eq "Item added to cart"
      end

      it "prevents adding more than available stock" do
        post "/users/#{@user.id}/carts", {
          product_id: @product.id,
          quantity: 15
        }

        expect(last_response.status).to eq 400
        expect(resp[:error]).to eq "Insufficient stock"
      end
    end

    describe "GET /users/:user_id/carts" do
      before do
        CartItem.create(
          user_id: @user.id,
          product_id: @product.id,
          quantity: 2
        )
      end

      it "returns cart contents" do
        get "/users/#{@user.id}/carts"

        expect(last_response.status).to eq 200
        expect(resp[:items].length).to eq 1
        expect(resp[:items][0][:product_name]).to eq "Laptop"
        expect(resp[:items][0][:quantity]).to eq 2
        expect(resp[:summary][:total_items]).to eq 2
        expect(resp[:summary][:formatted_total]).to eq "$1999.98"
      end
    end
  end

  describe "Orders" do
    before do
      @user = User.create(
        email: "test@example.com",
        password_hash: "hashed_password",
        first_name: "John",
        last_name: "Doe"
      )
      @category = Category.create(name: "Electronics")
      @product = Product.create(
        name: "Laptop",
        price: 999.99,
        stock_quantity: 10,
        category_id: @category.id
      )
      @cart_item = CartItem.create(
        user_id: @user.id,
        product_id: @product.id,
        quantity: 1
      )
    end

    describe "POST /orders" do
      it "creates order from cart" do
        post '/orders', {
          user_id: @user.id,
          shipping_address: "123 Main St, City, State 12345"
        }

        expect(last_response.status).to eq 201
        expect(resp[:order][:total_amount]).to eq "999.99"
        expect(resp[:order][:status]).to eq "pending"
        expect(resp[:message]).to eq "Order created successfully"

        # Verify cart was cleared
        expect(CartItem.where(user_id: @user.id).count).to eq 0

        # Verify stock was reduced
        @product.reload
        expect(@product.stock_quantity).to eq 9
      end

      it "prevents order creation with empty cart" do
        CartItem.where(user_id: @user.id).delete

        post '/orders', {
          user_id: @user.id,
          shipping_address: "123 Main St, City, State 12345"
        }

        expect(last_response.status).to eq 400
        expect(resp[:error]).to eq "Cart is empty"
      end
    end

    describe "GET /orders/:id" do
      before do
        @order = Order.create(
          user_id: @user.id,
          total_amount: 999.99,
          shipping_address: "123 Main St",
          status: "pending"
        )
        OrderItem.create(
          order_id: @order.id,
          product_id: @product.id,
          quantity: 1,
          unit_price: 999.99,
          total_price: 999.99
        )
      end

      it "returns order details" do
        get "/orders/#{@order.id}"

        expect(last_response.status).to eq 200
        expect(resp[:order][:total_amount]).to eq "999.99"
        expect(resp[:order][:status]).to eq "pending"
        expect(resp[:order][:items].length).to eq 1
        expect(resp[:order][:items][0][:product_name]).to eq "Laptop"
      end
    end

    describe "POST /orders/:id" do
      before do
        @order = Order.create(
          user_id: @user.id,
          total_amount: 999.99,
          shipping_address: "123 Main St",
          status: "pending"
        )
      end

      it "updates order status" do
        post "/orders/#{@order.id}", {
          status: "confirmed"
        }

        expect(last_response.status).to eq 200
        expect(resp[:order][:status]).to eq "confirmed"
        expect(resp[:message]).to eq "Order updated successfully"
      end
    end
  end
end
