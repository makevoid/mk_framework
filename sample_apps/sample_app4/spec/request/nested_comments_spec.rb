# frozen_string_literal: true

require_relative '../spec_helper'

module SampleApp4
  RSpec.describe 'Nested comments and persistence boundaries' do
    before do
      Comment.dataset.delete
      Post.dataset.delete
      @parent = Post.create(title: 'Owner')
      @other = Post.create(title: 'Other')
      @comment = Comment.create(post_id: @parent.id, content: 'Original')
    end

    def nested(parent = @parent)
      "/posts/#{parent.id}/comments/#{@comment.id}"
    end

    it 'shows, updates, and deletes a member through its URL parent' do
      get nested
      expect(last_response.status).to eq(200)
      expect(resp[:id]).to eq(@comment.id)
      patch nested, JSON.generate(content: 'Updated'), 'CONTENT_TYPE' => 'application/json'
      expect(last_response.status).to eq(200)
      expect(@comment.refresh.content).to eq('Updated')
      delete nested
      expect(last_response.status).to eq(200)
      expect(Comment[@comment.id]).to be_nil
    end

    it 'rejects wrong-parent reads and mutations without changing the record' do
      get nested(@other)
      expect(last_response.status).to eq(404)
      patch nested(@other), content: 'Unauthorized change'
      expect(last_response.status).to eq(404)
      delete nested(@other)
      expect(last_response.status).to eq(404)
      expect(@comment.refresh.content).to eq('Original')
    end

    it 'uses the URL parent even when query and body try to supply another parent' do
      post "/posts/#{@parent.id}/comments?post_id=#{@other.id}",
           JSON.generate(post_id: @other.id, content: 'Safe'), 'CONTENT_TYPE' => 'application/json'
      expect(last_response.status).to eq(201)
      expect(resp[:comment][:post_id]).to eq(@parent.id)
    end

    it 'saves a new comment once and returns 422 without inserting invalid data' do
      calls = 0
      allow_any_instance_of(Comment).to receive(:save).and_wrap_original do |original, *args|
        calls += 1
        original.call(*args)
      end
      post "/posts/#{@parent.id}/comments", content: 'Once'
      expect(last_response.status).to eq(201)
      expect(calls).to eq(1)
      expect { post "/posts/#{@parent.id}/comments", author: 'No content' }.not_to change(Comment, :count)
      expect(last_response.status).to eq(422)
      expect(last_response.content_type).to eq('application/json')
    end

    it 'runs parent destroy hooks and enforces cascading foreign keys' do
      expect_any_instance_of(Post).to receive(:before_destroy).once.and_call_original
      delete "/posts/#{@parent.id}"
      expect(last_response.status).to eq(200)
      expect(Comment[@comment.id]).to be_nil
      expect { Comment.create(post_id: @parent.id, content: 'Orphan') }.to raise_error(Sequel::ForeignKeyConstraintViolation)
    end

    it 'updates timestamps and limits nested collections' do
      old = Time.now - 3600
      @comment.update(updated_at: old)
      Comment.create(post_id: @parent.id, content: 'Second')
      get "/posts/#{@parent.id}/comments", limit: 1
      expect(resp.length).to eq(1)
      patch nested, content: 'Changed'
      expect(last_response.status).to eq(200)
      expect(@comment.refresh.updated_at).to be > old
    end

    it 'does not expose a parentless comment collection' do
      get '/comments'
      expect(last_response.status).to eq(404)
      post '/comments', content: 'No parent'
      expect(last_response.status).to eq(404)
    end
  end
end
