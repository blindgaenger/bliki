require "rubygems"
require "lib/datetime"
require "rdiscount"

Dir["lib/*.rb"].each { |f| require f }
Dir["plugins/*.rb"].each { |f| require f }
#Dir["app/views/*.rb"].each { |f| require f }

# submodules
require "lib/sinatra/lib/sinatra"
require "lib/sinatra-cache/lib/cache"
require "lib/stone/lib/stone"
require "lib/sinatra-rest/lib/rest"




#####################################################################################
# Setup
def stone_start
  datastore_dir = File.join(Dir.pwd, "db/#{Sinatra.env.to_s}")
  model_files = Dir.glob(File.join(Dir.pwd, "app/models/*"))
  Stone.start(datastore_dir, model_files)
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
  Dir["lib/*.rb"].each { |f| load f }
  Dir["plugins/*.rb"].each { |f| load f }
  stone_start
  load_config
  set_options_for :development
end

#####################################################################################

helpers do
  Dir["app/helpers/*.rb"].each { |f| load f }  
end

before do
  content_type 'text/html', :charset => 'utf-8'
end


rest Page, {:renderer => :erb} do
  def index
    puts 'CUSTOM index'
    super
  end
end


# controllers
Dir["app/controllers/*.rb"].each { |f| load f }

