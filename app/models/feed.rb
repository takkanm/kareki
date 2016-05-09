class Feed < ApplicationRecord
  class << self
    def crawl_and_push(subscriber_class)
      subscriber = subscriber_class.new

      all.each do |feed|
        feed.crawl_and_push(subscriber)
      end
    end
  end

  def crawl_and_push(subscriber)
    parser = Parser.load(feed_text)

    parser.each_items do |item|
      subscriber.push(item)
    end
  end

  def feed_text
    Net::HTTP.get(URI.parse(url))
  end
end
