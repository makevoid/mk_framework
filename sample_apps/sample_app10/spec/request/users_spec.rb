# frozen_string_literal: true

require 'spec_helper'

describe "Users" do
  before(:each) do
    # Clean up database
    Comment.dataset.delete
    Task.dataset.delete
    Project.dataset.delete
    User.dataset.delete
  end

  describe "GET /users" do
    before do
      @admin = User.create(
        name: "Admin User",
        email: "admin@example.com",
        password_hash: BCrypt::Password.create("password123"),
        role: "admin"
      )

      @manager = User.create(
        name: "Manager User",
        email: "manager@example.com",
        password_hash: BCrypt::Password.create("password123"),
        role: "manager"
      )

      @member = User.create(
        name: "Member User",
        email: "member@example.com",
        password_hash: BCrypt::Password.create("password123"),
        role: "member",
        active: false
      )
    end

    it "returns all users" do
      get '/users'

      expect(last_response.status).to eq 200
      
      users = resp[:users]
      expect(users.length).to eq 3
      expect(resp[:total]).to eq 3
      
      user_names = users.map { |u| u[:name] }
      expect(user_names).to include("Admin User", "Manager User", "Member User")
    end

    it "filters users by role" do
      get '/users?role=admin'

      expect(last_response.status).to eq 200
      
      users = resp[:users]
      expect(users.length).to eq 1
      expect(users[0][:name]).to eq "Admin User"
      expect(users[0][:role]).to eq "admin"
    end

    it "filters users by active status" do
      get '/users?active=true'

      expect(last_response.status).to eq 200
      
      users = resp[:users]
      expect(users.length).to eq 2
      users.each do |user|
        expect(user[:active]).to eq true
      end
    end

    it "filters users by inactive status" do
      get '/users?active=false'

      expect(last_response.status).to eq 200
      
      users = resp[:users]
      expect(users.length).to eq 1
      expect(users[0][:name]).to eq "Member User"
      expect(users[0][:active]).to eq false
    end
  end

  describe "GET /users/:id" do
    before do
      @user = User.create(
        name: "Test User",
        email: "test@example.com",
        password_hash: BCrypt::Password.create("password123"),
        role: "member"
      )
    end

    context "when user exists" do
      it "returns the user" do
        get "/users/#{@user.id}"

        expect(last_response.status).to eq 200
        expect(resp[:id]).to eq @user.id
        expect(resp[:name]).to eq "Test User"
        expect(resp[:email]).to eq "test@example.com"
        expect(resp[:role]).to eq "member"
        expect(resp[:password_hash]).to be_nil # Should not expose password hash
      end
    end

    context "when user does not exist" do
      it "returns a 404 error" do
        get "/users/999999"

        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "User not found"
      end
    end
  end

  describe "POST /users" do
    context "with valid parameters" do
      it "creates a new user" do
        post '/users', {
          name: "New User",
          email: "newuser@example.com",
          password: "securepassword",
          role: "manager"
        }

        expect(last_response.status).to eq 201
        expect(resp[:message]).to eq "User created successfully"
        expect(resp[:user][:name]).to eq "New User"
        expect(resp[:user][:email]).to eq "newuser@example.com"
        expect(resp[:user][:role]).to eq "manager"
        expect(resp[:user][:active]).to eq true

        # Verify password was hashed
        created_user = User[resp[:user][:id]]
        expect(created_user.authenticate("securepassword")).to eq true
      end

      it "creates a user with default role" do
        post '/users', {
          name: "Default Role User",
          email: "default@example.com",
          password: "password123"
        }

        expect(last_response.status).to eq 201
        expect(resp[:user][:role]).to eq "member"
      end
    end

    context "with invalid parameters" do
      it "returns validation errors for missing name" do
        post '/users', {
          email: "test@example.com",
          password: "password123"
        }

        expect(last_response.status).to eq 422
        expect(resp[:error]).to eq "Failed to create user"
        expect(resp[:details]).to be_a(Hash)
      end

      it "returns validation errors for invalid email" do
        post '/users', {
          name: "Test User",
          email: "invalid-email",
          password: "password123"
        }

        expect(last_response.status).to eq 422
        expect(resp[:error]).to eq "Failed to create user"
        expect(resp[:details]).to be_a(Hash)
      end

      it "returns validation errors for duplicate email" do
        User.create(
          name: "First User",
          email: "duplicate@example.com",
          password_hash: BCrypt::Password.create("password123")
        )

        post '/users', {
          name: "Second User",
          email: "duplicate@example.com",
          password: "password123"
        }

        expect(last_response.status).to eq 422
        expect(resp[:error]).to eq "Failed to create user"
        expect(resp[:details]).to be_a(Hash)
      end

      it "returns validation errors for invalid role" do
        post '/users', {
          name: "Test User",
          email: "test@example.com",
          password: "password123",
          role: "invalid_role"
        }

        expect(last_response.status).to eq 422
        expect(resp[:error]).to eq "Failed to create user"
        expect(resp[:details]).to be_a(Hash)
      end
    end
  end

  describe "POST /users/:id" do
    before do
      @user = User.create(
        name: "Original User",
        email: "original@example.com",
        password_hash: BCrypt::Password.create("password123"),
        role: "member"
      )
    end

    context "when user exists" do
      it "updates the user" do
        post "/users/#{@user.id}", {
          name: "Updated User",
          email: "updated@example.com",
          role: "manager",
          active: false
        }

        expect(last_response.status).to eq 200
        expect(resp[:message]).to eq "User updated successfully"
        expect(resp[:user][:name]).to eq "Updated User"
        expect(resp[:user][:email]).to eq "updated@example.com"
        expect(resp[:user][:role]).to eq "manager"
        expect(resp[:user][:active]).to eq false
      end

      it "updates the user password" do
        post "/users/#{@user.id}", {
          password: "newpassword123"
        }

        expect(last_response.status).to eq 200
        
        # Verify password was updated
        updated_user = User[@user.id]
        expect(updated_user.authenticate("newpassword123")).to eq true
        expect(updated_user.authenticate("password123")).to eq false
      end
    end

    context "when user does not exist" do
      it "returns a 404 error" do
        post "/users/999999", {
          name: "Updated User"
        }

        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "User not found"
      end
    end
  end

  describe "POST /users/:id/delete" do
    before do
      @user = User.create(
        name: "User to Delete",
        email: "delete@example.com",
        password_hash: BCrypt::Password.create("password123")
      )
    end

    context "when user exists" do
      it "deletes the user" do
        post "/users/#{@user.id}/delete"

        expect(last_response.status).to eq 200
        expect(resp[:message]).to eq "User deleted successfully"
        expect(resp[:user][:name]).to eq "User to Delete"

        # Verify user was deleted
        expect(User[@user.id]).to be_nil
      end
    end

    context "when user does not exist" do
      it "returns a 404 error" do
        post "/users/999999/delete"

        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "User not found"
      end
    end
  end
end