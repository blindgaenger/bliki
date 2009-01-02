rest Page, :renderer => :erb do
  def before
    auth
  end
  
  def index
    super
    @pages.sort! {|a,b| a.title.downcase <=> b.title.downcase}
  end
end

#####################################################
#### New

get '/:slug/new' do
  auth
  @page = Page.new(:title => params[:slug], :tags => '')
  @verb = :post
  erb(:edit)
end
post '/:slug/new' do
  auth
  @page = Page.new(params)
  redirect @page.link
end

#blog
get '/new' do
  auth
  @page = Page.new
  @verb = :post
  erb(:edit)
end
post '/new' do
  auth
  page = Page.new(params)
  expire_cache "/"
  expire_cache "/feed/"
  # Ping
  pingomatic
  redirect "/"
end


#### View
#['/:slug', '/:slug/'].each do |route|
#  get route do
#    params[:slug].downcase!
#    @page = Page.first(:nicetitle => params[:slug])
#    if @page.nil?
#      redirect "/#{params[:slug]}/new"
#    else
#      cache(erb(:view))
#    end
#  end
#end

#blog
['/:year/:month/:day/:slug/','/page/:slug'].each do |route|
  get route do
    @page = Page.first :nicetitle => params[:slug]
    cache(erb(:view))
  end
end

#### Edit
get '/:id/edit' do
  auth
  @page = Page[params[:id]]
  @verb = :put
  erb(:edit)
end
put '/:id/edit' do
  auth
  page = Page[params[:id]]
  page.update_attributes(params)
  expire_cache page.link
  redirect page.link
end

#blog
get '/page/:id/edit' do
  auth
  @page = Page[params[:id]]
  @verb = :put  
  erb(:edit)
end
put '/page/:id/edit' do
  auth
  
  attachment_params = params.delete("attachment")
  
  page = Page[params[:id]]
  page.update_attributes(params)

  unless attachment_params.nil?
    filename = attachment_params[:filename]
    file = attachment_params[:tempfile]
    attachment = Attachment.new(
      :page_id => page.id,
      :name => filename,
      :link => File.join('/', 'attachments', filename),
      :path => File.join(Sinatra.options.public, 'attachments'),
      :content => File.open(File.expand_path(file.path)) #TODO: refactor the attachment model
    )
    
    unless attachment.save
      warn "could not save attachment #{filename}"
    end
  end
  
  expire_cache "/"
  expire_cache "/feed/"
  expire_cache page.link
  redirect page.link
end

#### delete
get '/:id/delete' do
  auth
  @page = Page[params[:id]]
  erb(:delete)
end
delete '/:id/delete' do
  auth
  page = Page[params[:id]]
  expire_cache page.link
  Page.delete(page.id)   
  redirect '/'
end

#blog
get '/page/:id/delete' do
  auth
  @page = Page[params[:id]]
  erb(:delete)
end
delete '/page/:id/delete' do
  auth
  page = Page[params[:id]]
  expire_cache page.link
  Page.delete(page.id)   
  redirect '/'
end
