require "rubygems"
require "lib/datetime"
require "lib/sinatra/lib/sinatra"
require "lib/sinatra-cache/lib/cache"
require "lib/stone/lib/stone"
require "rdiscount"
Dir["lib/*.rb"].each { |f| require f }
Dir["lib/plugin/*.rb"].each { |f| require f }


#####################################################################################
# Setup
def stone_start
  Stone.start(Dir.pwd + "/db/#{Sinatra.env.to_s}", Dir.glob(File.join(Dir.pwd,"models/*")))
end
def load_config
  YAML::load(File.read('config.yml')).to_hash.each do |k,v|
    set k, v
  end
  theme = Sinatra.options.theme || "default"
  set :views, "themes/#{theme}"
end
def set_options_for env
  Sinatra.options.send(env).each do |k,v|
    set k, v
  end
end
configure do
  stone_start
  load_config
end
configure :development do
  set :cache_enabled, false
  set :ping, false
  set_options_for :development
end
configure :production do
  disable :logging
  set_options_for :production
  not_found do
    redirect "/"
  end
  error do
    redirect "/"
  end
end
configure :test do
  set :cache_enabled, false
  set_options_for :test
end
if development?
  Dir["lib/*.rb"].each do |f|
    load f
  end
  Dir["lib/plugin/*.rb"].each do |f|
    load f
  end
  stone_start
  load_config
  set_options_for :development
end


before do
  content_type 'text/html', :charset => 'utf-8'
  @tags = ((Page.all.collect { |p| p.tags.split(",").collect { |t| t.strip } }.flatten) + (Page.all.collect { |p| p.tags.split(",").collect { |t| t.strip } }.flatten)).uniq.sort
end

#####################################################################################
# Atom Feed
get '/feed/' do
  content_type 'application/atom+xml', :charset => "utf-8"
  @pages = Page.all(:order => {:updated_at => :desc}).first(Sinatra.options.limit)
  cache(builder(:feed))
end


#####################################################################################
# Home
get '/' do
  all_pages = Page.all(:order => {:created_at => :desc})
  @pages = all_pages.first(Sinatra.options.limit)
  if all_pages.size > Sinatra.options.limit
    @archives = all_pages[(Sinatra.options.limit)...Sinatra.options.limit*2]
  end
  cache(erb(:home))
end

#####################################################################################
#### Wiki
#####################################################################################

#### New
get '/:slug/new' do
  auth
  @page = Page.new(:title => params[:slug], :tags => '')
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
['/:slug', '/:slug/'].each do |route|
  get route do
    params[:slug].downcase!
    @page = Page.first(:nicetitle => params[:slug])
    if @page.nil?
      redirect "/#{params[:slug]}/new"
    else
      cache(erb(:view))
    end
  end
end

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


#####################################################################################
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


#####################################################################################
# CSS
get '/base.css' do
  cache(sass(:base))
end

# Theme support
get '/:type/:filename.:ext' do
  send_file "themes/#{Sinatra.options.theme}/#{params[:type]}/#{params[:filename]}.#{params[:ext]}", :disposition => "inline"
end

