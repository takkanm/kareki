module Subscriber
  class Idobata
    def initialize
      @hook_url = ENV['IDOBATA_SUBSCRIBER_HOOK_URL']
      @client   = IdobataHook::Client.new(@hook_url)
    end

    def push(item)
      message = create_message(item)

      @client.send(message, format: :html)
    end

    def error_push(message)
      @client.send(message, format: :html)
    end

    private

    def create_message(item)
      "#{item.blog_title.force_encoding('UTF-8')} post: <b>「#{item.title.force_encoding('UTF-8')}」</b> #{item.link.force_encoding('UTF-8')}"
    end
  end
end
