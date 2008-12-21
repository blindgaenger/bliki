# Archive: View Tag
get '/tag/:name' do
  @tag = params[:name]
  all_pages = (Page.all :tags.includes => @tag,:order => {:created_at => :desc}) + (Page.all :tags.includes => @tag,:order => {:created_at => :desc})
  @pages = all_pages.first(Sinatra.options.limit)
  if all_pages.size > Sinatra.options.limit
    @archives = all_pages[(Sinatra.options.limit)...all_pages.size]
  end
  erb(:archive)
end
