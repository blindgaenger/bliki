get '/' do
  @pages = Page.latest(@app.limit)
  erb :news
end

