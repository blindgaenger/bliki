# CSS
get '/base.css' do
  cache(sass(:base))
end

