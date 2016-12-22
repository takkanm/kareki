module Parser
  def self.load(text)
    ox = Ox.parse(text)

    [Parser::Atom, Parser::Rss1, Parser::Rss].each do |parser_class|
      if parser_class.applicable?(ox)
        return parser_class.new(ox)
      end
    end

    raise
  end

  class Base
    def self.applicable?(doc)
      false
    end

    def initialize(document)
      @document = document
    end

    def each_items
      raise
    end
  end

  class Atom < Base
    class << self
      def applicable?(doc)
        find_url(doc) == 'http://www.w3.org/2005/Atom'
      end

      private

      def find_url(doc)
        if doc.respond_to?(:xmlns)
          doc.xmlns
        elsif doc.nodes.first.attributes[:xmlns]
          doc.nodes.first.attributes[:xmlns]
        else
          nil
        end
      end
    end

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
        published_at: Time.zone.parse(date_text(elem)),
        author:       elem.author.nodes.map(&:text).join('&')
      )
    end

    def date_text(elem)
      if elem.respond_to?(:published)
        elem.published.text
      else
        elem.updated.text
      end
    end

    def find_or_blank_node(elem, node_name)
      elem.locate(node_name).first&.text
    end
  end

  class Rss < Base
    def self.applicable?(doc)
      return false unless doc.root.respond_to?(:value)

      doc.root.value == 'rss'
    end

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
    def self.applicable?(doc)
      return false unless doc.root.respond_to?(:xmlns)

      doc.root.xmlns == 'http://purl.org/rss/1.0/'
    end

    private

    def item_nodes
      @document.root.nodes
    end

    def date_text(elem)
      elem.locate('dc:date').first.text
    end
  end
end
