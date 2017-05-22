module Subscriber
  class Slack
    def initialize
      @token   = ENV['SLACK_TOKEN']
      @channel = ENV['SLACK_CHANNEL']
      @as_user = ENV['SLACK_AS_USER'].present?

      @client = Slack::Web::Client.new(token: @token)
    end

    def push(item)
      message = create_message(item)

      post_message(message)
    end

    def error_push(message)
      post_message(message)
    end

    private

    def post_message(message)
      @client.chat_postMessage(channel: @channel, text: message, as_user: @as_user)
    end

    def create_message(item)
      "#{item.blog_title.force_encoding('UTF-8')} post: <b>「#{item.title.force_encoding('UTF-8')}」</b> #{item.link.force_encoding('UTF-8')}"
    end
  end
end
