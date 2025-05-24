# frozen_string_literal: true

require 'spec_helper'

describe "Tasks" do
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
  end

  describe "GET /tasks" do
    before do
      @task1 = Task.create(
        title: "Implement login",
        description: "Add user authentication",
        status: "todo",
        priority: "high",
        project_id: @project.id,
        assigned_to_id: @developer.id,
        created_by_id: @manager.id
      )

      @task2 = Task.create(
        title: "Write tests",
        description: "Add unit tests",
        status: "in_progress",
        priority: "medium",
        project_id: @project.id,
        created_by_id: @manager.id
      )
    end

    it "returns all tasks" do
      get '/tasks'

      expect(last_response.status).to eq 200
      
      tasks = resp[:tasks]
      expect(tasks.length).to eq 2
      expect(resp[:total]).to eq 2
      
      task_titles = tasks.map { |t| t[:title] }
      expect(task_titles).to include("Implement login", "Write tests")
    end

    it "filters tasks by project" do
      get "/tasks?project_id=#{@project.id}"

      expect(last_response.status).to eq 200
      
      tasks = resp[:tasks]
      expect(tasks.length).to eq 2
      tasks.each do |task|
        expect(task[:project_id]).to eq @project.id
      end
    end

    it "filters tasks by assigned user" do
      get "/tasks?assigned_to_id=#{@developer.id}"

      expect(last_response.status).to eq 200
      
      tasks = resp[:tasks]
      expect(tasks.length).to eq 1
      expect(tasks[0][:title]).to eq "Implement login"
      expect(tasks[0][:assigned_to_id]).to eq @developer.id
    end

    it "filters tasks by status" do
      get "/tasks?status=todo"

      expect(last_response.status).to eq 200
      
      tasks = resp[:tasks]
      expect(tasks.length).to eq 1
      expect(tasks[0][:status]).to eq "todo"
    end

    it "filters tasks by priority" do
      get "/tasks?priority=high"

      expect(last_response.status).to eq 200
      
      tasks = resp[:tasks]
      expect(tasks.length).to eq 1
      expect(tasks[0][:priority]).to eq "high"
    end

    it "includes associations when requested" do
      get "/tasks?include_associations=true"

      expect(last_response.status).to eq 200
      
      tasks = resp[:tasks]
      task_with_assignment = tasks.find { |t| t[:assigned_to_id] }
      
      expect(task_with_assignment[:project][:name]).to eq "Test Project"
      expect(task_with_assignment[:assigned_to][:name]).to eq "Developer"
      expect(task_with_assignment[:created_by][:name]).to eq "Project Manager"
    end
  end

  describe "GET /tasks/:id" do
    before do
      @task = Task.create(
        title: "Test Task",
        description: "A test task",
        project_id: @project.id,
        created_by_id: @manager.id
      )
    end

    context "when task exists" do
      it "returns the task with associations" do
        get "/tasks/#{@task.id}"

        expect(last_response.status).to eq 200
        expect(resp[:id]).to eq @task.id
        expect(resp[:title]).to eq "Test Task"
        expect(resp[:project][:name]).to eq "Test Project"
        expect(resp[:created_by][:name]).to eq "Project Manager"
      end
    end

    context "when task does not exist" do
      it "returns a 404 error" do
        get "/tasks/999999"

        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "Task not found"
      end
    end
  end

  describe "POST /tasks" do
    context "with valid parameters" do
      it "creates a new task" do
        post '/tasks', {
          title: "New Task",
          description: "A brand new task",
          project_id: @project.id,
          created_by_id: @manager.id,
          assigned_to_id: @developer.id,
          priority: "high",
          due_date: "2024-12-31",
          estimated_hours: 8
        }

        expect(last_response.status).to eq 201
        expect(resp[:message]).to eq "Task created successfully"
        expect(resp[:task][:title]).to eq "New Task"
        expect(resp[:task][:priority]).to eq "high"
        expect(resp[:task][:estimated_hours]).to eq 8
        expect(resp[:task][:assigned_to][:name]).to eq "Developer"
      end
    end

    context "with invalid project" do
      it "returns a 404 error" do
        post '/tasks', {
          title: "New Task",
          project_id: 999999,
          created_by_id: @manager.id
        }

        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "Project not found"
      end
    end

    context "with invalid parameters" do
      it "returns validation errors" do
        post '/tasks', {
          description: "Task without title",
          project_id: @project.id,
          created_by_id: @manager.id
        }

        expect(last_response.status).to eq 422
        expect(resp[:error]).to eq "Failed to create task"
        expect(resp[:details]).to be_a(Hash)
      end
    end
  end

  describe "POST /tasks/:id" do
    before do
      @task = Task.create(
        title: "Original Task",
        description: "Original description",
        status: "todo",
        project_id: @project.id,
        created_by_id: @manager.id
      )
    end

    context "when task exists" do
      it "updates the task" do
        post "/tasks/#{@task.id}", {
          title: "Updated Task",
          status: "in_progress",
          priority: "critical",
          actual_hours: 4
        }

        expect(last_response.status).to eq 200
        expect(resp[:message]).to eq "Task updated successfully"
        expect(resp[:task][:title]).to eq "Updated Task"
        expect(resp[:task][:status]).to eq "in_progress"
        expect(resp[:task][:priority]).to eq "critical"
        expect(resp[:task][:actual_hours]).to eq 4
      end

      it "sets completed_at when status changes to done" do
        post "/tasks/#{@task.id}", {
          status: "done"
        }

        expect(last_response.status).to eq 200
        expect(resp[:task][:status]).to eq "done"
        expect(resp[:task][:completed_at]).not_to be_nil
      end
    end

    context "when task does not exist" do
      it "returns a 404 error" do
        post "/tasks/999999", {
          title: "Updated Task"
        }

        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "Task not found"
      end
    end
  end

  describe "POST /tasks/:id/assign" do
    before do
      @task = Task.create(
        title: "Task to Assign",
        project_id: @project.id,
        created_by_id: @manager.id
      )
    end

    context "when task and user exist" do
      it "assigns the task to the user" do
        post "/tasks/#{@task.id}/assign", {
          user_id: @developer.id
        }

        expect(last_response.status).to eq 200
        expect(resp[:message]).to eq "Task assigned to Developer"
        expect(resp[:task][:assigned_to][:name]).to eq "Developer"
      end

      it "unassigns the task when user_id is nil" do
        @task.update(assigned_to_id: @developer.id)

        post "/tasks/#{@task.id}/assign", {
          user_id: nil
        }

        expect(last_response.status).to eq 200
        expect(resp[:message]).to eq "Task unassigned"
        expect(resp[:task][:assigned_to_id]).to be_nil
      end
    end

    context "when user does not exist" do
      it "returns a 404 error" do
        post "/tasks/#{@task.id}/assign", {
          user_id: 999999
        }

        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "User not found"
      end
    end

    context "when task does not exist" do
      it "returns a 404 error" do
        post "/tasks/999999/assign", {
          user_id: @developer.id
        }

        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "Task not found"
      end
    end
  end

  describe "POST /tasks/:id/delete" do
    before do
      @task = Task.create(
        title: "Task to Delete",
        project_id: @project.id,
        created_by_id: @manager.id
      )
    end

    context "when task exists" do
      it "deletes the task" do
        post "/tasks/#{@task.id}/delete"

        expect(last_response.status).to eq 200
        expect(resp[:message]).to eq "Task deleted successfully"
        expect(resp[:task][:title]).to eq "Task to Delete"

        # Verify task was deleted
        expect(Task[@task.id]).to be_nil
      end
    end

    context "when task does not exist" do
      it "returns a 404 error" do
        post "/tasks/999999/delete"

        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "Task not found"
      end
    end
  end
end