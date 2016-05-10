module Parser
  def self.load(text)
    ox = Ox.parse(text)
    if ox.root.respond_to?(:xmlns)
      case ox.root.xmlns
      when 'http://www.w3.org/2005/Atom'
        Parser::Atom.new(ox.root)
      when 'http://purl.org/rss/1.0/'
        Parser::Rss1.new(ox)
      end
    else
      if ox.root.value == 'rss'
-      Parser::Rss.new(ox)
      else
        raise
      end
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
        description:  find_or_blank_node(elem, 'summary'),
        published_at: Time.zone.parse(elem.published.text),
        author:       elem.author.nodes.map(&:text).join('&')
      )
    end

    def find_or_blank_node(elem, node_name)
      elem.locate(node_name).first&.text
    end
  end

  class Rss < Base
    def initialize(document)
      super
      @channel    = @document.root.channel
      @blog_title = @channel.title.text
    end

    def each_items
      item_nodes.each do |elem|
        next unless elem.value == 'item'

        yield build_feed_item(elem)
      end
    end

    private

    def item_nodes
      @channel.nodes
    end

    def build_feed_item(elem)
      FeedItem.new(
        blog_title:   @blog_title,
        title:        elem.title.text,
        link:         elem.link.text,
        description:  elem.description.text,
        published_at: Time.zone.parse(date_text(elem)),
        author:       nil
      )
    end

    def date_text(elem)
      elem.pubDate.text
    end
  end

  class Rss1 < Rss
    private

    def item_nodes
      @document.root.nodes
    end

    def date_text(elem)
      elem.locate('dc:date').first.text
    end
  end
end
