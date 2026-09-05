# frozen_string_literal: true

module SampleApp4
  class PostsIndexController < Controller
    route do |r|
      page = r.page
      posts = Post.order(:id).limit(page[:limit], page[:offset])
      posts = posts.eager(:comments) if r.params['comments'] == '1'
      posts.all.map do |post|
        attributes = post.values.dup
        if r.params['comments'] == '1'
          attributes[:comments] = post.comments
        end
        attributes
      end
    end
  end
end
