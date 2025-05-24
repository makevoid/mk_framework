# frozen_string_literal: true

require 'spec_helper'

describe "Projects" do
  before(:each) do
    # Clean up database
    Comment.dataset.delete
    Task.dataset.delete
    Project.dataset.delete
    User.dataset.delete

    # Create test users
    @owner = User.create(
      name: "John Doe",
      email: "john@example.com",
      password_hash: BCrypt::Password.create("password123"),
      role: "manager"
    )

    @member = User.create(
      name: "Jane Smith",
      email: "jane@example.com",
      password_hash: BCrypt::Password.create("password123"),
      role: "member"
    )
  end

  describe "GET /projects" do
    before do
      @project1 = Project.create(
        name: "Website Redesign",
        description: "Complete overhaul of company website",
        status: "active",
        owner_id: @owner.id
      )

      @project2 = Project.create(
        name: "Mobile App",
        description: "New mobile application",
        status: "completed",
        owner_id: @owner.id
      )

      @archived_project = Project.create(
        name: "Archived Project",
        description: "This project is archived",
        status: "active",
        archived: true,
        owner_id: @owner.id
      )
    end

    it "returns all non-archived projects" do
      get '/projects'

      expect(last_response.status).to eq 200
      
      projects = resp[:projects]
      expect(projects.length).to eq 2
      expect(resp[:total]).to eq 2
      
      project_names = projects.map { |p| p[:name] }
      expect(project_names).to include("Website Redesign", "Mobile App")
      expect(project_names).not_to include("Archived Project")
    end

    it "filters projects by status" do
      get '/projects?status=active'

      expect(last_response.status).to eq 200
      
      projects = resp[:projects]
      expect(projects.length).to eq 1
      expect(projects[0][:name]).to eq "Website Redesign"
      expect(projects[0][:status]).to eq "active"
    end

    it "filters projects by owner" do
      get "/projects?owner_id=#{@owner.id}"

      expect(last_response.status).to eq 200
      
      projects = resp[:projects]
      expect(projects.length).to eq 2
      projects.each do |project|
        expect(project[:owner_id]).to eq @owner.id
      end
    end

    it "includes statistics when requested" do
      # Create some tasks for the project
      Task.create(
        title: "Task 1",
        status: "todo",
        project_id: @project1.id,
        created_by_id: @owner.id
      )
      
      Task.create(
        title: "Task 2",
        status: "done",
        project_id: @project1.id,
        created_by_id: @owner.id
      )

      get '/projects?include_stats=true'

      expect(last_response.status).to eq 200
      
      projects = resp[:projects]
      project_with_tasks = projects.find { |p| p[:id] == @project1.id }
      
      expect(project_with_tasks[:task_statistics]).to include(
        total: 2,
        todo: 1,
        done: 1,
        in_progress: 0,
        review: 0
      )
      expect(project_with_tasks[:owner][:name]).to eq "John Doe"
    end
  end

  describe "GET /projects/:id" do
    before do
      @project = Project.create(
        name: "Test Project",
        description: "A test project",
        owner_id: @owner.id
      )
    end

    context "when project exists" do
      it "returns the project with statistics" do
        get "/projects/#{@project.id}"

        expect(last_response.status).to eq 200
        expect(resp[:id]).to eq @project.id
        expect(resp[:name]).to eq "Test Project"
        expect(resp[:description]).to eq "A test project"
        expect(resp[:task_statistics]).to be_a(Hash)
      end
    end

    context "when project does not exist" do
      it "returns a 404 error" do
        get "/projects/999999"

        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "Project not found"
      end
    end
  end

  describe "POST /projects" do
    context "with valid parameters" do
      it "creates a new project" do
        post '/projects', {
          name: "New Project",
          description: "A brand new project",
          owner_id: @owner.id,
          start_date: "2024-01-01",
          end_date: "2024-12-31"
        }

        expect(last_response.status).to eq 201
        expect(resp[:message]).to eq "Project created successfully"
        expect(resp[:project][:name]).to eq "New Project"
        expect(resp[:project][:description]).to eq "A brand new project"
        expect(resp[:project][:owner_id]).to eq @owner.id
        expect(resp[:project][:status]).to eq "active"
      end
    end

    context "with invalid parameters" do
      it "returns validation errors" do
        post '/projects', {
          description: "Project without name",
          owner_id: @owner.id
        }

        expect(last_response.status).to eq 422
        expect(resp[:error]).to eq "Failed to create project"
        expect(resp[:details]).to be_a(Hash)
      end
    end
  end

  describe "POST /projects/:id" do
    before do
      @project = Project.create(
        name: "Original Project",
        description: "Original description",
        owner_id: @owner.id
      )
    end

    context "when project exists" do
      it "updates the project" do
        post "/projects/#{@project.id}", {
          name: "Updated Project",
          description: "Updated description",
          status: "completed"
        }

        expect(last_response.status).to eq 200
        expect(resp[:message]).to eq "Project updated successfully"
        expect(resp[:project][:name]).to eq "Updated Project"
        expect(resp[:project][:description]).to eq "Updated description"
        expect(resp[:project][:status]).to eq "completed"
      end
    end

    context "when project does not exist" do
      it "returns a 404 error" do
        post "/projects/999999", {
          name: "Updated Project"
        }

        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "Project not found"
      end
    end
  end

  describe "POST /projects/:id/delete" do
    before do
      @project = Project.create(
        name: "Project to Delete",
        owner_id: @owner.id
      )
    end

    context "when project exists" do
      it "deletes the project" do
        post "/projects/#{@project.id}/delete"

        expect(last_response.status).to eq 200
        expect(resp[:message]).to eq "Project deleted successfully"
        expect(resp[:project][:name]).to eq "Project to Delete"

        # Verify project was deleted
        expect(Project[@project.id]).to be_nil
      end
    end

    context "when project does not exist" do
      it "returns a 404 error" do
        post "/projects/999999/delete"

        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "Project not found"
      end
    end
  end

  describe "POST /projects/:id/archive" do
    before do
      @project = Project.create(
        name: "Project to Archive",
        owner_id: @owner.id
      )
    end

    context "when project exists" do
      it "archives the project" do
        post "/projects/#{@project.id}/archive"

        expect(last_response.status).to eq 200
        expect(resp[:message]).to eq "Project archived successfully"
        expect(resp[:project][:archived]).to eq true

        # Verify project was archived
        archived_project = Project[@project.id]
        expect(archived_project.archived).to eq true
      end
    end

    context "when project does not exist" do
      it "returns a 404 error" do
        post "/projects/999999/archive"

        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "Project not found"
      end
    end
  end
end