get '/' do
#  @pages = Page.latest(Sinatra.options.limit)

  @pages = Page.all(:order => {:updated_at => :desc}).first(@app.limit)

#  all_pages = Page.all(:order => {:created_at => :desc})
#  @pages = all_pages.first(Sinatra.options.limit)

#  if all_pages.size > Sinatra.options.limit
#    @archives = all_pages[(Sinatra.options.limit)...Sinatra.options.limit*2]
#  end

  erb :news
end

