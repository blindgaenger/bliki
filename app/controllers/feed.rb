# Atom Feed
get '/feed/' do
  content_type 'application/atom+xml', :charset => "utf-8"
  @pages = Page.latest(Sinatra.options.limit)
  cache(builder(:feed))
end
