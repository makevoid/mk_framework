# frozen_string_literal: true

require 'spec_helper'

describe "Todos" do
  describe "POST /todos" do
    context "with valid parameters" do
      it "creates a new todo" do
        post '/todos', {
          title: "Test Todo",
          description: "This is a test todo"
        }

        expect(last_response.status).to eq(201)
        
        json_response = JSON.parse(last_response.body)
        expect(json_response['message']).to eq("Todo created")
        expect(json_response['todo']['title']).to eq("Test Todo")
        expect(json_response['todo']['description']).to eq("This is a test todo")
        expect(json_response['todo']['completed']).to eq(false)
      end
    end
    
    context "with invalid parameters" do
      it "returns validation errors when title is missing" do
        post '/todos', {
          description: "This todo has no title"
        }
        
        expect(last_response.status).to eq(422)
        
        json_response = JSON.parse(last_response.body)
        expect(json_response['error']).to eq("Validation failed")
        expect(json_response['details']).to have_key('title')
      end
      
      it "returns validation errors when title is too long" do
        post '/todos', {
          title: "X" * 101,
          description: "This todo has a title that is too long"
        }
        
        expect(last_response.status).to eq(422)
        
        json_response = JSON.parse(last_response.body)
        expect(json_response['error']).to eq("Validation failed")
        expect(json_response['details']).to have_key('title')
      end
    end
  end
end