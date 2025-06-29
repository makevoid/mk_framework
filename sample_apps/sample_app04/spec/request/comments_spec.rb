# frozen_string_literal: true

require 'spec_helper'

describe "Comments" do
  before do
    # Clean up the database
    Comment.dataset.delete
    Post.dataset.delete

    # Create a test post
    @post = Post.create(
      title: "Test Post",
      description: "This is a test post for comments"
    )
  end

  describe "GET /posts/:post_id/comments" do
    before do
      # Add some comments to the post
      @comment1 = Comment.create(
        post_id: @post.id,
        content: "First comment",
        author: "Alice"
      )

      @comment2 = Comment.create(
        post_id: @post.id,
        content: "Second comment",
        author: "Bob"
      )

      # Add a comment to a non-existent post (should not be returned)
      @comment3 = Comment.create(
        post_id: @post.id + 1,
        content: "Comment on another post",
        author: "Charlie"
      ) rescue nil
    end

    it "returns all comments for a post" do
      get "/posts/#{@post.id}/comments"

      expect(last_response.status).to eq 200
      expect(resp.length).to eq 2

      expect(resp[0][:id]).to eq @comment1.id
      expect(resp[0][:content]).to eq "First comment"
      expect(resp[0][:author]).to eq "Alice"

      expect(resp[1][:id]).to eq @comment2.id
      expect(resp[1][:content]).to eq "Second comment"
      expect(resp[1][:author]).to eq "Bob"
    end

    it "returns a 404 error for a non-existent post" do
      get "/posts/999999/comments"

      expect(last_response.status).to eq 404
      expect(resp[:error]).to eq "Post not found"
    end
  end

  describe "GET /comments/:id" do
    before do
      @comment = Comment.create(
        post_id: @post.id,
        content: "Test comment",
        author: "Alice"
      )
    end

    it "returns the comment" do
      get "/comments/#{@comment.id}"

      expect(last_response.status).to eq 200
      expect(resp[:id]).to eq @comment.id
      expect(resp[:content]).to eq "Test comment"
      expect(resp[:author]).to eq "Alice"
      expect(resp[:post_id]).to eq @post.id
    end

    it "returns a 404 error for a non-existent comment" do
      get "/comments/999999"

      expect(last_response.status).to eq 404
      expect(resp[:error]).to eq "Comment not found"
    end
  end

  describe "POST /posts/:post_id/comments" do
    it "creates a new comment" do
      post "/posts/#{@post.id}/comments", {
        content: "New comment",
        author: "Alice"
      }

      expect(last_response.status).to eq 201
      expect(resp[:message]).to eq "Comment created"
      expect(resp[:comment][:content]).to eq "New comment"
      expect(resp[:comment][:author]).to eq "Alice"
      expect(resp[:comment][:post_id]).to eq @post.id
    end

    it "creates a comment without an author" do
      post "/posts/#{@post.id}/comments", {
        content: "Anonymous comment"
      }

      expect(last_response.status).to eq 201
      expect(resp[:message]).to eq "Comment created"
      expect(resp[:comment][:content]).to eq "Anonymous comment"
      expect(resp[:comment][:author]).to be_nil
    end

    it "returns validation errors when content is missing" do
      post "/posts/#{@post.id}/comments", {
        author: "Alice"
      }

      expect(last_response.status).to eq 422
      expect(resp[:error]).to eq "Validation failed"
      expect(resp[:details]).to have_key :content
    end

    it "returns a 404 error for a non-existent post" do
      post "/posts/999999/comments", {
        content: "Comment on non-existent post",
        author: "Alice"
      }

      expect(last_response.status).to eq 404
      expect(resp[:error]).to eq "Post not found"
    end
  end

  describe "PUT /comments/:id" do
    before do
      @comment = Comment.create(
        post_id: @post.id,
        content: "Original content",
        author: "Original author"
      )
    end

    it "updates the comment content" do
      post "/comments/#{@comment.id}", {
        content: "Updated content"
      }

      expect(last_response.status).to eq 200
      expect(resp[:message]).to eq "Comment updated"
      expect(resp[:comment][:id]).to eq @comment.id
      expect(resp[:comment][:content]).to eq "Updated content"
      expect(resp[:comment][:author]).to eq "Original author"
    end

    it "updates the comment author" do
      post "/comments/#{@comment.id}", {
        author: "Updated author"
      }

      expect(last_response.status).to eq 200
      expect(resp[:message]).to eq "Comment updated"
      expect(resp[:comment][:id]).to eq @comment.id
      expect(resp[:comment][:content]).to eq "Original content"
      expect(resp[:comment][:author]).to eq "Updated author"
    end

    it "updates multiple fields at once" do
      post "/comments/#{@comment.id}", {
        content: "Completely updated",
        author: "New author"
      }

      expect(last_response.status).to eq 200
      expect(resp[:message]).to eq "Comment updated"
      expect(resp[:comment][:id]).to eq @comment.id
      expect(resp[:comment][:content]).to eq "Completely updated"
      expect(resp[:comment][:author]).to eq "New author"
    end

    it "returns a 404 error for a non-existent comment" do
      post "/comments/999999", {
        content: "Updated content"
      }

      expect(last_response.status).to eq 404
      expect(resp[:error]).to eq "Comment not found"
    end
  end

  describe "DELETE /comments/:id" do
    before do
      @comment = Comment.create(
        post_id: @post.id,
        content: "Comment to delete",
        author: "Alice"
      )
    end

    it "deletes the comment" do
      post "/comments/#{@comment.id}/delete"

      expect(last_response.status).to eq 200
      expect(resp[:message]).to eq "Comment deleted successfully"
      expect(resp[:comment][:id]).to eq @comment.id
      expect(resp[:comment][:content]).to eq "Comment to delete"
      expect(resp[:comment][:author]).to eq "Alice"

      # Verify that the comment was actually deleted from the database
      expect(Comment[@comment.id]).to be_nil
    end

    it "returns a 404 error for a non-existent comment" do
      post "/comments/999999/delete"

      expect(last_response.status).to eq 404

      expect(resp).to have_key :error
      expect(resp[:error]).to eq "Comment not found"
    end
  end
end
