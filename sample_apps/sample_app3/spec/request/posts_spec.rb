# frozen_string_literal: true

require 'spec_helper'

describe "Posts" do
  describe "GET /posts" do
    before do
      Post.dataset.delete

      @post1 = Post.create(
        title: "First Post",
        description: "This is the first test blog post"
      )

      @post2 = Post.create(
        title: "Second Post",
        description: "This is the second test blog post"
      )
    end

    it "returns all posts" do
      get '/posts'

      expect(last_response.status).to eq 200

      expect(resp.length).to eq 2

      expect(resp[0][:id]).to eq @post1.id
      expect(resp[0][:title]).to eq "First Post"
      expect(resp[0][:description]).to eq "This is the first test blog post"

      expect(resp[1][:id]).to eq @post2.id
      expect(resp[1][:title]).to eq "Second Post"
      expect(resp[1][:description]).to eq "This is the second test blog post"
    end
  end

  describe "GET /posts/:id" do
    before do
      Post.dataset.delete

      @post = Post.create(
        title: "Test Post",
        description: "This is a test blog post"
      )
    end

    context "when post exists" do
      it "returns the post" do
        get "/posts/#{@post.id}"

        expect(last_response.status).to eq 200

        expect(resp[:id]).to eq @post.id
        expect(resp[:title]).to eq "Test Post"
        expect(resp[:description]).to eq "This is a test blog post"
      end
    end

    context "when post does not exist" do
      it "returns a 404 error" do
        get "/posts/999999"

        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "Post not found"
      end
    end
  end

  describe "POST /posts" do
    context "with valid parameters" do
      it "creates a new post" do
        post '/posts', {
          title: "Test Post",
          description: "This is a test blog post"
        }

        expect(last_response.status).to eq 201

        expect(resp[:message]).to eq "Post created"
        expect(resp[:post][:title]).to eq "Test Post"
        expect(resp[:post][:description]).to eq "This is a test blog post"
      end
    end

    context "with invalid parameters" do
      it "returns validation errors when title is missing" do
        post '/posts', {
          description: "This post has no title"
        }

        expect(last_response.status).to eq 422

        expect(resp[:error]).to eq "Validation failed"
        expect(resp[:details]).to have_key :title
      end

      it "returns validation errors when title is too long" do
        post '/posts', {
          title: "X" * 101,
          description: "This post has a title that is too long"
        }

        expect(last_response.status).to eq 422

        expect(resp[:error]).to eq "Validation failed"
        expect(resp[:details]).to have_key :title
      end
    end
  end

  describe "PUT /posts/:id" do
    before do
      Post.dataset.delete

      @post = Post.create(
        title: "Original Title",
        description: "Original Description"
      )
    end

    context "when post exists" do
      it "updates the post title" do
        post "/posts/#{@post.id}", {
          title: "Updated Title"
        }

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Post updated"
        expect(resp[:post][:id]).to eq @post.id
        expect(resp[:post][:title]).to eq "Updated Title"
        expect(resp[:post][:description]).to eq "Original Description"
      end

      it "updates the post description" do
        post "/posts/#{@post.id}", {
          description: "Updated Description"
        }

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Post updated"
        expect(resp[:post][:id]).to eq @post.id
        expect(resp[:post][:title]).to eq "Original Title"
        expect(resp[:post][:description]).to eq "Updated Description"
      end

      it "updates multiple fields at once" do
        post "/posts/#{@post.id}", {
          title: "Completely Updated",
          description: "New Description"
        }

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Post updated"
        expect(resp[:post][:id]).to eq @post.id
        expect(resp[:post][:title]).to eq "Completely Updated"
        expect(resp[:post][:description]).to eq "New Description"
      end

      it "returns validation errors when title is too long" do
        post "/posts/#{@post.id}", {
          title: "X" * 101
        }

        expect(last_response.status).to eq 400

        expect(resp[:error]).to eq "Validation failed!"
        expect(resp[:details]).to have_key :title
      end
    end

    context "when post does not exist" do
      it "returns a 404 error" do
        post "/posts/999999", {
          title: "Updated Title"
        }

        expect(last_response.status).to eq 404
        expect(resp[:message]).to eq "post not found"
      end
    end
  end

  describe "DELETE /posts/:id" do
    before do
      Post.dataset.delete

      @post = Post.create(
        title: "Post to Delete",
        description: "This post will be deleted"
      )
    end

    context "when post exists" do
      it "deletes the post" do
        post "/posts/#{@post.id}/delete"

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Post deleted successfully"
        expect(resp[:post][:id]).to eq @post.id
        expect(resp[:post][:title]).to eq "Post to Delete"
        expect(resp[:post][:description]).to eq "This post will be deleted"

        # Verify that the post was actually deleted from the database
        expect(Post[@post.id]).to be_nil
      end
    end

    context "when post does not exist" do
      it "returns a 404 error" do
        delete "/posts/999999"

        expect(last_response.status).to eq 404
        expect(resp).to be_empty
      end
    end
  end
end