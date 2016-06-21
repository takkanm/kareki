class Feed < ApplicationRecord
  class << self
    def crawl_and_push(subscriber_class)
      subscriber = subscriber_class.new

      all.each do |feed|
        begin
          feed.crawl_and_push(subscriber)
        rescue => e
          Rails.logger.error "feed('#{feed.title}(#{feed.id}) has error : #{e.inspect}"
          Rails.logger.error e.backtrace
        end
      end
    end
  end

  def crawl_and_push(subscriber)
    parser = Parser.load(feed_text)

    parser.each_items do |item|
      subscriber.push(item) if crawled_at&.< item.published_at
    end

    self.crawled_at = Time.now
    save!
  end

  def feed_text
    HTTPClient.get(url).body
  end
end
