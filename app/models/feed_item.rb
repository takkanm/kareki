class FeedItem
  include ActiveModel::Model

  attr_accessor :blog_title, :title, :link, :description, :published_at, :author
end
