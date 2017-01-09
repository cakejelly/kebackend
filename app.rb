require 'json'

post '/' do
  'Hello world'
end

def extract_params(content)
  # Extracts the content we need
  # for fetching
end

post '/kebabfetcher' do
  request.body.rewind  # in case someone already read it
  data = JSON.parse request.body.read
  puts JSON.pretty_generate(data)
end
