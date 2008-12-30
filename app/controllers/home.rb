# Home
get '/' do
  all_pages = Page.all(:order => {:created_at => :desc})
  @pages = all_pages.first(Sinatra.options.limit)
  if all_pages.size > Sinatra.options.limit
    @archives = all_pages[(Sinatra.options.limit)...Sinatra.options.limit*2]
  end
  cache(erb(:home))
end

