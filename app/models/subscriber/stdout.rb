module Subscriber
  class Stdout
    def push(item)
      puts create_message(item)
    end

    def error_push(message)
      puts message
    end

    private

    def create_message(item)
      "#{item.blog_title.force_encoding('UTF-8')} post: <b>「#{item.title.force_encoding('UTF-8')}」</b> #{item.link.force_encoding('UTF-8')}"
    end
  end
end
