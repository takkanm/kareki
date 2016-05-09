module Parser
  def self.load(text)
    ox = Ox.parse(text)
    if ox.value == 'feed'
      Parser::Atom.new(ox)
    elsif ox.value.nil? && ox.root.value == 'rss'
      Parser::Rss.new(ox)
    else
      raise
    end
  end

  class Base
    def initialize(document)
      @document= document
    end

    def each_items
      raise
    end
  end

  class Atom < Base
    def each_items
      @blog_title = @document.title.text

      @document.nodes.each do |elem|
        next unless elem.value == 'entry'

        yield build_feed_item(elem)
      end
    end

    private

    def build_feed_item(elem)
      FeedItem.new(
        blog_title:   @blog_title,
        title:        elem.title.text,
        link:         elem.link.href,
        description:  elem.summary.text,
        published_at: Time.zone.parse(elem.published.text),
        author:       elem.author.nodes.map(&:text).join('&')
      )
    end
  end

  class Rss < Base
    def initialize(document)
      super
      @channel    = @document.root.channel
      @blog_title = @channel.title.text
    end

    def each_items
      @channel.nodes.each do |elem|
        next unless elem.value == 'item'

        yield build_feed_item(elem)
      end
    end

    private

    def build_feed_item(elem)
      FeedItem.new(
        blog_title:   @blog_title,
        title:        elem.title.text,
        link:         elem.link.text,
        description:  elem.description.text,
        published_at: Time.zone.parse(elem.pubDate.text),
        author:       nil
      )
    end
  end
end
