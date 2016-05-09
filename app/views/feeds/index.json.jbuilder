json.array!(@feeds) do |feed|
  json.extract! feed, :id, :url, :last_updated_at, :title
  json.url feed_url(feed, format: :json)
end
