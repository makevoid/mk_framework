# frozen_string_literal: true

require 'spec_helper'

describe "Cards" do
  describe "GET /cards" do
    before do
      Comment.dataset.delete
      Card.dataset.delete

      @card1 = Card.create(
        title: "First Card",
        description: "This is the first kanban card",
        status: "todo"
      )

      @card2 = Card.create(
        title: "Second Card",
        description: "This is the second kanban card",
        status: "in_progress"
      )
      
      @card3 = Card.create(
        title: "Third Card",
        description: "This is the third kanban card",
        status: "done"
      )
    end

    it "returns all cards" do
      get '/cards'

      expect(last_response.status).to eq 200

      expect(resp[:cards].length).to eq 3

      expect(resp[:cards][0][:id]).to eq @card1.id
      expect(resp[:cards][0][:title]).to eq "First Card"
      expect(resp[:cards][0][:description]).to eq "This is the first kanban card"
      expect(resp[:cards][0][:status]).to eq "todo"

      expect(resp[:cards][1][:id]).to eq @card2.id
      expect(resp[:cards][1][:title]).to eq "Second Card"
      expect(resp[:cards][1][:description]).to eq "This is the second kanban card"
      expect(resp[:cards][1][:status]).to eq "in_progress"
      
      expect(resp[:cards][2][:id]).to eq @card3.id
      expect(resp[:cards][2][:title]).to eq "Third Card"
      expect(resp[:cards][2][:description]).to eq "This is the third kanban card"
      expect(resp[:cards][2][:status]).to eq "done"
    end
  end

  describe "GET /cards/:id" do
    before do
      Card.dataset.delete
      Comment.dataset.delete

      @card = Card.create(
        title: "Test Card",
        description: "This is a test kanban card",
        status: "todo"
      )
      
      @comment1 = Comment.create(
        card_id: @card.id,
        content: "First comment",
        author: "Alice"
      )
      
      @comment2 = Comment.create(
        card_id: @card.id,
        content: "Second comment",
        author: "Bob"
      )
    end

    context "when card exists" do
      it "returns the card with its comments" do
        get "/cards/#{@card.id}"

        expect(last_response.status).to eq 200

        # Check card data
        expect(resp[:card][:id]).to eq @card.id
        expect(resp[:card][:title]).to eq "Test Card"
        expect(resp[:card][:description]).to eq "This is a test kanban card"
        expect(resp[:card][:status]).to eq "todo"
        
        # Check comments
        expect(resp[:comments].length).to eq 2
        
        expect(resp[:comments][0][:id]).to eq @comment1.id
        expect(resp[:comments][0][:content]).to eq "First comment"
        expect(resp[:comments][0][:author]).to eq "Alice"
        
        expect(resp[:comments][1][:id]).to eq @comment2.id
        expect(resp[:comments][1][:content]).to eq "Second comment"
        expect(resp[:comments][1][:author]).to eq "Bob"
      end
    end

    context "when card does not exist" do
      it "returns a 404 error" do
        get "/cards/999999"

        expect(last_response.status).to eq 404
        expect(resp[:error]).to eq "Card not found"
      end
    end
  end

  describe "POST /cards" do
    before do
      Comment.dataset.delete
      Card.dataset.delete
    end
    
    context "with valid parameters" do
      it "creates a new card" do
        post '/cards', {
          title: "Test Card",
          description: "This is a test kanban card",
          status: "todo"
        }

        expect(last_response.status).to eq 201

        expect(resp[:message]).to eq "Card created"
        expect(resp[:card][:title]).to eq "Test Card"
        expect(resp[:card][:description]).to eq "This is a test kanban card"
        expect(resp[:card][:status]).to eq "todo"
      end
      
      it "creates a new card with default status" do
        post '/cards', {
          title: "Test Card",
          description: "This is a test kanban card"
        }

        expect(last_response.status).to eq 201

        expect(resp[:message]).to eq "Card created"
        expect(resp[:card][:title]).to eq "Test Card"
        expect(resp[:card][:description]).to eq "This is a test kanban card"
        expect(resp[:card][:status]).to eq "todo"
      end
    end

    context "with invalid parameters" do
      it "returns validation errors when title is missing" do
        post '/cards', {
          description: "This card has no title"
        }

        expect(last_response.status).to eq 422

        expect(resp[:error]).to eq "Validation failed"
        expect(resp[:details]).to have_key :title
      end

      it "returns validation errors when title is too long" do
        post '/cards', {
          title: "X" * 101,
          description: "This card has a title that is too long"
        }

        expect(last_response.status).to eq 422

        expect(resp[:error]).to eq "Validation failed"
        expect(resp[:details]).to have_key :title
      end
      
      it "returns validation errors when status is invalid" do
        post '/cards', {
          title: "Test Card",
          description: "This is a test kanban card",
          status: "invalid_status"
        }

        expect(last_response.status).to eq 422

        expect(resp[:error]).to eq "Validation failed"
        expect(resp[:details]).to have_key :status
      end
    end
  end

  describe "PUT /cards/:id" do
    before do
      Comment.dataset.delete
      Card.dataset.delete

      @card = Card.create(
        title: "Original Title",
        description: "Original Description",
        status: "todo"
      )
    end

    context "when card exists" do
      it "updates the card title" do
        post "/cards/#{@card.id}", {
          title: "Updated Title"
        }

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Card updated"
        expect(resp[:card][:id]).to eq @card.id
        expect(resp[:card][:title]).to eq "Updated Title"
        expect(resp[:card][:description]).to eq "Original Description"
        expect(resp[:card][:status]).to eq "todo"
      end

      it "updates the card status" do
        post "/cards/#{@card.id}", {
          status: "in_progress"
        }

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Card updated"
        expect(resp[:card][:id]).to eq @card.id
        expect(resp[:card][:title]).to eq "Original Title"
        expect(resp[:card][:description]).to eq "Original Description"
        expect(resp[:card][:status]).to eq "in_progress"
      end
      
      it "moves a card to done" do
        post "/cards/#{@card.id}", {
          status: "done"
        }

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Card updated"
        expect(resp[:card][:id]).to eq @card.id
        expect(resp[:card][:status]).to eq "done"
      end

      it "updates multiple fields at once" do
        post "/cards/#{@card.id}", {
          title: "Completely Updated",
          description: "New Description",
          status: "done"
        }

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Card updated"
        expect(resp[:card][:id]).to eq @card.id
        expect(resp[:card][:title]).to eq "Completely Updated"
        expect(resp[:card][:description]).to eq "New Description"
        expect(resp[:card][:status]).to eq "done"
      end

      it "returns validation errors when title is too long" do
        post "/cards/#{@card.id}", {
          title: "X" * 101
        }

        expect(last_response.status).to eq 400

        expect(resp[:error]).to eq "Validation failed!"
        expect(resp[:details]).to have_key :title
      end
      
      it "returns validation errors when status is invalid" do
        post "/cards/#{@card.id}", {
          status: "invalid_status"
        }

        expect(last_response.status).to eq 400

        expect(resp[:error]).to eq "Validation failed!"
        expect(resp[:details]).to have_key :status
      end
    end

    context "when card does not exist" do
      it "returns a 404 error" do
        post "/cards/999999", {
          title: "Updated Title"
        }

        expect(last_response.status).to eq 404
        expect(resp[:message]).to eq "card not found"
      end
    end
  end

  describe "DELETE /cards/:id" do
    before do
      Comment.dataset.delete
      Card.dataset.delete

      @card = Card.create(
        title: "Card to Delete",
        description: "This card will be deleted",
        status: "todo"
      )
    end

    context "when card exists" do
      it "deletes the card" do
        post "/cards/#{@card.id}/delete"

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Card deleted successfully"
        expect(resp[:card][:id]).to eq @card.id
        expect(resp[:card][:title]).to eq "Card to Delete"
        expect(resp[:card][:description]).to eq "This card will be deleted"

        # Verify that the card was actually deleted from the database
        expect(Card[@card.id]).to be_nil
      end
    end

    context "when card does not exist" do
      it "returns a 404 error" do
        delete "/cards/999999"

        expect(last_response.status).to eq 404
        expect(resp).to be_empty
      end
    end
  end
end