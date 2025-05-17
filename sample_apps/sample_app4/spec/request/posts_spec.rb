# frozen_string_literal: true

require 'spec_helper'

describe "Cards" do
  describe "GET /cards" do
    before do
      Comment.dataset.delete
      Card.dataset.delete

      @card1 = Card.create(
        title: "First Task",
        description: "This is the first test task",
        status: "Todo"
      )

      @card2 = Card.create(
        title: "Second Task",
        description: "This is the second test task",
        status: "In Progress"
      )
    end

    it "returns all cards" do
      get '/cards'

      expect(last_response.status).to eq 200

      expect(resp.length).to eq 2

      expect(resp[0][:id]).to eq @card1.id
      expect(resp[0][:title]).to eq "First Task"
      expect(resp[0][:description]).to eq "This is the first test task"
      expect(resp[0][:status]).to eq "Todo"

      expect(resp[1][:id]).to eq @card2.id
      expect(resp[1][:title]).to eq "Second Task"
      expect(resp[1][:description]).to eq "This is the second test task"
      expect(resp[1][:status]).to eq "In Progress"
    end
  end

  describe "GET /cards/:id" do
    before do
      Card.dataset.delete
      Comment.dataset.delete

      @card = Card.create(
        title: "Test Card",
        description: "This is a test card",
        status: "Todo"
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
        expect(resp[:card][:description]).to eq "This is a test card"
        expect(resp[:card][:status]).to eq "Todo"

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
          description: "This is a test card",
          status: "Todo"
        }

        expect(last_response.status).to eq 201

        expect(resp[:message]).to eq "Card created"
        expect(resp[:card][:title]).to eq "Test Card"
        expect(resp[:card][:description]).to eq "This is a test card"
        expect(resp[:card][:status]).to eq "Todo"
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
          title: "Invalid Status Card",
          description: "This card has an invalid status",
          status: "Invalid"
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
        status: "Todo"
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
        expect(resp[:card][:status]).to eq "Todo"
      end

      it "updates the card description" do
        post "/cards/#{@card.id}", {
          description: "Updated Description"
        }

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Card updated"
        expect(resp[:card][:id]).to eq @card.id
        expect(resp[:card][:title]).to eq "Original Title"
        expect(resp[:card][:description]).to eq "Updated Description"
        expect(resp[:card][:status]).to eq "Todo"
      end

      it "updates the card status" do
        post "/cards/#{@card.id}", {
          status: "In Progress"
        }

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Card updated"
        expect(resp[:card][:id]).to eq @card.id
        expect(resp[:card][:title]).to eq "Original Title"
        expect(resp[:card][:description]).to eq "Original Description"
        expect(resp[:card][:status]).to eq "In Progress"
      end

      it "updates multiple fields at once" do
        post "/cards/#{@card.id}", {
          title: "Completely Updated",
          description: "New Description",
          status: "Done"
        }

        expect(last_response.status).to eq 200

        expect(resp[:message]).to eq "Card updated"
        expect(resp[:card][:id]).to eq @card.id
        expect(resp[:card][:title]).to eq "Completely Updated"
        expect(resp[:card][:description]).to eq "New Description"
        expect(resp[:card][:status]).to eq "Done"
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
          status: "Invalid Status"
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
        expect(resp[:error]).to eq "Card not found"
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
        status: "Todo"
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
        expect(resp[:card][:status]).to eq "Todo"

        # Verify that the card was actually deleted from the database
        expect(Card[@card.id]).to be_nil
      end
    end

    context "when card does not exist" do
      it "returns a 404 error" do
        post "/cards/999999/delete"

        expect(last_response.status).to eq 404
        expect(resp).to have_key :error
        expect(resp[:error]).to eq "Card not found"
      end
    end
  end
end