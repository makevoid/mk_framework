# frozen_string_literal: true

require_relative '../spec_helper'

module SampleApp4
  RSpec.describe 'Controller and handler data boundary' do
    before do
      Comment.dataset.delete
      Post.dataset.delete
      @post = Post.create(title: 'Post')
      @comment = Comment.create(post_id: @post.id, content: 'Reply')
    end

    def expect_plain_data(value)
      case value
      when Hash
        value.each_value { |item| expect_plain_data(item) }
      when Array
        value.each { |item| expect_plain_data(item) }
      else
        expect(value).not_to be_a(Sequel::Model)
        expect(value).not_to be_a(Sequel::Dataset)
      end
    end

    App.router.endpoints.each do |endpoint|
      it "passes raw data to #{endpoint[:handler]} without handler SQL via #{endpoint[:verb]} #{endpoint[:path].join('/')}" do
        handled = false
        allow_any_instance_of(endpoint[:handler]).to receive(:execute).and_wrap_original do |original, request|
          data = original.receiver.model
          expect(data.is_a?(Hash) || data.is_a?(Array)).to eq(true)
          expect_plain_data(data)
          sql = StringIO.new
          logger = Logger.new(sql)
          DB.loggers << logger
          begin
            result = original.call(request)
            expect(sql.string).to eq('')
            handled = true
            result
          ensure
            DB.loggers.delete(logger)
          end
        end

        path = endpoint[:path].map do |part|
          case part
          when :post_id then @post.id
          when :id then endpoint[:label] == 'Post' ? @post.id : @comment.id
          else part
          end
        end.join('/')
        public_send(endpoint[:verb].downcase, "/#{path}", title: 'Changed', content: 'Changed', comments: '1')

        expect(last_response.status).to eq(endpoint[:action] == :create ? 201 : 200)
        expect(handled).to eq(true)
      end
    end

    it 'formats and filters a raw post list including nested comments without reading request parameters' do
      data = [{id: 1, title: 'Post', internal_note: 'private', comments: [
        {id: 2, post_id: 1, content: 'Reply', moderation_note: 'private'}
      ]}]

      response = PostsIndexHandler.new(data).execute(nil)

      expect(response).to eq([{id: 1, title: 'Post', comments: [{id: 2, post_id: 1, content: 'Reply'}]}])
      expect(data.first).to have_key(:internal_note)
      expect(data.first[:comments].first).to have_key(:moderation_note)
    end

    it 'formats raw posts without adding an unrequested comments array' do
      expect(PostsIndexHandler.new([{id: 1, title: 'Post'}]).execute(nil)).to eq([{id: 1, title: 'Post'}])
    end
  end
end
