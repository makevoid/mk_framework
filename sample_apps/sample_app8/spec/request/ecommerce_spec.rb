# frozen_string_literal: true

require 'spec_helper'

describe "E-commerce API" do
  describe "Products" do
    before do
      CartItem.dataset.delete
      Cart.dataset.delete
      Product.dataset.delete
      
      @product1 = Product.create(
        name: "Premium Coffee Beans",
        description: "High-quality Arabica coffee beans",
        price: 24.99,
        stock: 50,
        sku: "COF-001",
        active: true
      )
      
      @product2 = Product.create(
        name: "Tea Blend",
        description: "Organic herbal tea blend",
        price: 15.99,
        stock: 30,
        sku: "TEA-001",
        active: true
      )
    end

    describe "GET /products" do
      it "returns all active products" do
        get '/products'

        expect(last_response.status).to eq 200
        
        products = resp
        expect(products.length).to eq 2
        expect(products[0][:name]).to eq "Premium Coffee Beans"
        expect(products[0][:price]).to eq 24.99
        expect(products[1][:name]).to eq "Tea Blend"
        expect(products[1][:price]).to eq 15.99
      end
      
      it "filters products by price range" do
        get '/products?min_price=20'
        
        expect(last_response.status).to eq 200
        products = resp
        expect(products.length).to eq 1
        expect(products[0][:name]).to eq "Premium Coffee Beans"
      end
    end

    describe "GET /products/:id" do
      it "returns a specific product" do
        get "/products/#{@product1.id}"

        expect(last_response.status).to eq 200
        expect(resp[:id]).to eq @product1.id
        expect(resp[:name]).to eq "Premium Coffee Beans"
        expect(resp[:price]).to eq 24.99
      end

      it "returns 404 for non-existent product" do
        get "/products/999999"

        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "Product not found"
      end
    end

    describe "POST /products" do
      it "creates a new product" do
        post '/products', {
          name: "New Product",
          description: "A test product",
          price: 19.99,
          stock: 25,
          sku: "NEW-001"
        }

        expect(last_response.status).to eq 201
        expect(resp[:message]).to eq "Product created successfully"
        expect(resp[:product][:name]).to eq "New Product"
        expect(resp[:product][:price]).to eq 19.99
      end
    end
  end

  describe "Cart" do
    before do
      CartItem.dataset.delete
      Cart.dataset.delete
      Product.dataset.delete
      
      @product = Product.create(
        name: "Test Product",
        price: 10.00,
        stock: 100,
        active: true
      )
      
      @session_id = "test_session_123"
    end

    describe "GET /cart/:session_id" do
      it "returns empty cart for new session" do
        get "/cart/#{@session_id}"

        expect(last_response.status).to eq 200
        expect(resp[:session_id]).to eq @session_id
        expect(resp[:total]).to eq 0.0
        expect(resp[:items]).to be_empty
      end
    end

    describe "POST /cart/:session_id/products" do
      it "adds item to cart" do
        post "/cart/#{@session_id}/products", {
          product_id: @product.id,
          quantity: 2
        }

        puts "Response status: #{last_response.status}"
        puts "Response body: #{last_response.body}"
        puts "Parsed response: #{resp}"
        
        expect(last_response.status).to eq 200
        expect(resp[:message]).to eq "Item added to cart"
        expect(resp[:cart][:total]).to eq 20.0
        expect(resp[:cart][:item_count]).to eq 2
      end

      it "returns error for insufficient stock" do
        post "/cart/#{@session_id}/products", {
          product_id: @product.id,
          quantity: 150
        }

        expect(last_response.status).to eq 422
        expect(resp[:error]).to eq "Insufficient stock"
      end
    end
  end

  describe "Checkout" do
    before do
      Order.dataset.delete
      CartItem.dataset.delete
      Cart.dataset.delete
      Product.dataset.delete
      
      @product = Product.create(
        name: "Checkout Product",
        price: 25.00,
        stock: 10,
        active: true
      )
      
      @session_id = "checkout_session"
      @cart = Cart.create(session_id: @session_id)
      @cart.add_item(@product, 2)
    end

    describe "POST /checkouts" do
      it "creates order and reduces stock" do
        initial_stock = @product.stock
        
        post '/checkouts', {
          session_id: @session_id,
          customer_email: "test@example.com",
          customer_name: "John Doe",
          shipping_address: "123 Main St",
          payment_method: "credit_card"
        }

        expect(last_response.status).to eq 201
        expect(resp[:message]).to eq "Order placed successfully"
        expect(resp[:order][:total]).to eq 50.0
        expect(resp[:order][:customer_email]).to eq "test@example.com"
        
        # Verify stock was reduced
        @product.reload
        expect(@product.stock).to eq initial_stock - 2
        
        # Verify cart was cleared
        @cart.reload
        expect(@cart.cart_items).to be_empty
      end

      it "returns error for empty cart" do
        empty_cart = Cart.create(session_id: "empty_session")
        
        post '/checkouts', {
          session_id: "empty_session",
          customer_email: "test@example.com",
          customer_name: "John Doe",
          shipping_address: "123 Main St"
        }

        expect(last_response.status).to eq 422
        expect(resp[:error]).to eq "Cart is empty"
      end
    end
  end
end
