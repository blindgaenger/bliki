# CSS
get '/base.css' do
  cache(sass(:base))
end

# Theme support
get '/:type/:filename.:ext' do
  send_file "themes/#{Sinatra.options.theme}/#{params[:type]}/#{params[:filename]}.#{params[:ext]}", :disposition => "inline"
end
