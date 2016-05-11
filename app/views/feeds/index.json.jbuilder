json.array!(@feeds) do |feed|
  json.extract! feed, :id, :url, :crawled_at, :title
  json.url feed_url(feed, format: :json)
end
