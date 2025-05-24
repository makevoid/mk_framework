# frozen_string_literal: true

require 'spec_helper'

describe "Comments" do
  before(:each) do
    # Clean up database
    Comment.dataset.delete
    Task.dataset.delete
    Project.dataset.delete
    User.dataset.delete

    # Create test users
    @manager = User.create(
      name: "Project Manager",
      email: "manager@example.com",
      password_hash: BCrypt::Password.create("password123"),
      role: "manager"
    )

    @developer = User.create(
      name: "Developer",
      email: "dev@example.com",
      password_hash: BCrypt::Password.create("password123"),
      role: "member"
    )

    # Create test project
    @project = Project.create(
      name: "Test Project",
      description: "A project for testing",
      owner_id: @manager.id
    )

    # Create test tasks
    @task1 = Task.create(
      title: "Implement feature",
      description: "Add new feature",
      project_id: @project.id,
      created_by_id: @manager.id
    )

    @task2 = Task.create(
      title: "Fix bug",
      description: "Fix critical bug",
      project_id: @project.id,
      created_by_id: @manager.id
    )
  end

  describe "GET /comments" do
    before do
      @comment1 = Comment.create(
        content: "This looks good to me",
        task_id: @task1.id,
        user_id: @manager.id
      )

      @comment2 = Comment.create(
        content: "I'll work on this tomorrow",
        task_id: @task1.id,
        user_id: @developer.id
      )

      @comment3 = Comment.create(
        content: "Bug reproduced successfully",
        task_id: @task2.id,
        user_id: @developer.id
      )
    end

    it "returns all comments" do
      get '/comments'

      expect(last_response.status).to eq 200
      
      comments = resp[:comments]
      expect(comments.length).to eq 3
      expect(resp[:total]).to eq 3
      
      comment_contents = comments.map { |c| c[:content] }
      expect(comment_contents).to include(
        "This looks good to me",
        "I'll work on this tomorrow",
        "Bug reproduced successfully"
      )
    end

    it "filters comments by task" do
      get "/comments?task_id=#{@task1.id}"

      expect(last_response.status).to eq 200
      
      comments = resp[:comments]
      expect(comments.length).to eq 2
      comments.each do |comment|
        expect(comment[:task_id]).to eq @task1.id
      end
    end

    it "filters comments by user" do
      get "/comments?user_id=#{@developer.id}"

      expect(last_response.status).to eq 200
      
      comments = resp[:comments]
      expect(comments.length).to eq 2
      comments.each do |comment|
        expect(comment[:user_id]).to eq @developer.id
        expect(comment[:user][:name]).to eq "Developer"
      end
    end

    it "returns comments in chronological order" do
      get '/comments'

      expect(last_response.status).to eq 200
      
      comments = resp[:comments]
      expect(comments.length).to eq 3
      
      # Verify comments are ordered by created_at
      timestamps = comments.map { |c| DateTime.parse(c[:created_at]) }
      expect(timestamps).to eq(timestamps.sort)
    end

    it "includes user information in comments" do
      get '/comments'

      expect(last_response.status).to eq 200
      
      comments = resp[:comments]
      comment_with_user = comments.first
      
      expect(comment_with_user[:user]).to include(
        id: @manager.id,
        name: "Project Manager"
      )
    end
  end

  describe "POST /comments" do
    context "with valid parameters" do
      it "creates a new comment" do
        post '/comments', {
          content: "This is a test comment",
          task_id: @task1.id,
          user_id: @developer.id
        }

        expect(last_response.status).to eq 201
        expect(resp[:message]).to eq "Comment created successfully"
        expect(resp[:comment][:content]).to eq "This is a test comment"
        expect(resp[:comment][:task_id]).to eq @task1.id
        expect(resp[:comment][:user_id]).to eq @developer.id
        expect(resp[:comment][:user][:name]).to eq "Developer"
      end

      it "creates a comment with long content" do
        long_content = "This is a very long comment that contains multiple sentences. " * 10

        post '/comments', {
          content: long_content,
          task_id: @task1.id,
          user_id: @manager.id
        }

        expect(last_response.status).to eq 201
        expect(resp[:comment][:content]).to eq long_content
      end
    end

    context "with invalid task" do
      it "returns a 404 error" do
        post '/comments', {
          content: "Comment on non-existent task",
          task_id: 999999,
          user_id: @developer.id
        }

        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "Task not found"
      end
    end

    context "with invalid parameters" do
      it "returns validation errors for missing content" do
        post '/comments', {
          task_id: @task1.id,
          user_id: @developer.id
        }

        expect(last_response.status).to eq 422
        expect(resp[:error]).to eq "Failed to create comment"
        expect(resp[:details]).to be_a(Hash)
      end

      it "returns validation errors for empty content" do
        post '/comments', {
          content: "",
          task_id: @task1.id,
          user_id: @developer.id
        }

        expect(last_response.status).to eq 422
        expect(resp[:error]).to eq "Failed to create comment"
        expect(resp[:details]).to be_a(Hash)
      end

      it "returns validation errors for missing task_id" do
        post '/comments', {
          content: "Comment without task",
          user_id: @developer.id
        }

        expect(last_response.status).to eq 422
        expect(resp[:error]).to eq "Failed to create comment"
        expect(resp[:details]).to be_a(Hash)
      end

      it "returns validation errors for missing user_id" do
        post '/comments', {
          content: "Comment without user",
          task_id: @task1.id
        }

        expect(last_response.status).to eq 422
        expect(resp[:error]).to eq "Failed to create comment"
        expect(resp[:details]).to be_a(Hash)
      end
    end
  end

  describe "POST /comments/:id/delete" do
    before do
      @comment = Comment.create(
        content: "Comment to delete",
        task_id: @task1.id,
        user_id: @developer.id
      )
    end

    context "when comment exists" do
      it "deletes the comment" do
        post "/comments/#{@comment.id}/delete"

        expect(last_response.status).to eq 200
        expect(resp[:message]).to eq "Comment deleted successfully"
        expect(resp[:comment][:content]).to eq "Comment to delete"

        # Verify comment was deleted
        expect(Comment[@comment.id]).to be_nil
      end
    end

    context "when comment does not exist" do
      it "returns a 404 error" do
        post "/comments/999999/delete"

        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "Comment not found"
      end
    end
  end

  describe "GET /comments with task association" do
    before do
      @comment = Comment.create(
        content: "Great work on this task!",
        task_id: @task1.id,
        user_id: @manager.id
      )
    end

    it "allows filtering comments for a specific task" do
      get "/comments?task_id=#{@task1.id}"

      expect(last_response.status).to eq 200
      
      comments = resp[:comments]
      expect(comments.length).to eq 1
      expect(comments[0][:content]).to eq "Great work on this task!"
      expect(comments[0][:task_id]).to eq @task1.id
    end

    it "returns empty result for task with no comments" do
      get "/comments?task_id=#{@task2.id}"

      expect(last_response.status).to eq 200
      
      comments = resp[:comments]
      expect(comments.length).to eq 0
      expect(resp[:total]).to eq 0
    end
  end
end