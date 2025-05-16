# frozen_string_literal: true

require 'sequel'
require 'json'
require 'roda'
require_relative '../../lib/mk_framework'

# Set up database connection
DB = Sequel.connect('sqlite://blog.db')

# Drop existing tables to rebuild schema
DB.drop_table?(:comments) if DB.table_exists?(:comments)
DB.drop_table?(:posts) if DB.table_exists?(:posts)

# Create posts table
DB.create_table :posts do
  primary_key :id
  String :title, null: false
  String :description, text: true
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
end

# Create comments table
DB.create_table :comments do
  primary_key :id
  foreign_key :post_id, :posts, on_delete: :cascade, null: false
  String :content, null: false, text: true
  String :author
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
end

# Require models
require_relative 'models/post'
require_relative 'models/comment'

# Create application instance
class BlogApp < MK::Application
  # Override the route method to add our custom routes
  route do |r|
    # Default root route
    r.root do
      { message: "Welcome to the Blog API" }
    end

    # Custom nested routes for comments
    # GET /posts/:post_id/comments - List comments for a post
    r.get "posts", Integer do |post_id|
      r.is "comments" do
        r.params['post_id'] = post_id
        controller = CommentsIndexController.new
        result = controller.execute(r)
        handler = CommentsIndexHandler.new(result)
        handler.execute(r)
      end
    end
    
    # POST /posts/:post_id/comments - Create a comment for a post
    r.post "posts", Integer do |post_id|
      r.is "comments" do
        r.params['post_id'] = post_id
        controller = CommentsCreateController.new
        result = controller.execute(r)
        handler = CommentsCreateHandler.new(result)
        handler.execute(r)
      end
    end
    
    # GET /comments/:id - View a specific comment
    r.get "comments", Integer do |id|
      r.params['id'] = id
      controller = CommentsShowController.new
      result = controller.execute(r)
      handler = CommentsShowHandler.new(result)
      handler.execute(r)
    end
    
    # POST /comments/:id - Update a comment
    r.post "comments", Integer do |id|
      r.is do
        r.params['id'] = id
        controller = CommentsUpdateController.new
        result = controller.execute(r)
        handler = CommentsUpdateHandler.new(result)
        handler.execute(r)
      end
    end
    
    # POST /comments/:id/delete - Delete a comment
    r.post "comments", Integer, "delete" do |id|
      r.params['id'] = id
      controller = CommentsDeleteController.new
      result = controller.execute(r)
      handler = CommentsDeleteHandler.new(result)
      handler.execute(r)
    end
    
    # DELETE /comments/:id - Standard method for delete
    r.delete "comments", Integer do |id|
      r.params['id'] = id
      controller = CommentsDeleteController.new
      result = controller.execute(r)
      handler = CommentsDeleteHandler.new(result)
      handler.execute(r)
    end
  end
end
