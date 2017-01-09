require 'json'
require 'sinatra'

require_relative 'lib/foursquare_importer'
require_relative 'lib/yelp_importer'

get '/' do
  'Hello world'
end

def extract_params(content)
  # Extracts the content we need
  # for fetching
  location = content['fields']['location']['en-US']
  lat = location['lat']
  long = location['lon']
  lat_long = "#{lat},#{long}"

  entity_name = content['fields']['name']['en-US']

  # Needed to update / enrich the entry later
  entry_id = content['sys']['id']

  #puts "LatLong #{lat_long}, Name #{entity_name}, EntryID #{entry_id} "
  {
    location: lat_long,
    entity_name: entity_name,
    entry_id: entry_id
  }
end

post '/kebabfetcher' do
  request.body.rewind  # in case someone already read it
  data = JSON.parse request.body.read
  puts JSON.pretty_generate(data)
  enrich_params = extract_params(data)
 puts enrich_params
  entry_foursquare = FoursquareImporter.find(
    enrich_params[:entry_id], 
    enrich_params[:location],
    enrich_params[:entity_name])
  entry_yelp = YelpImporter.find(
    enrich_params[:entry_id], 
    enrich_params[:location],
    enrich_params[:entity_name])
  puts entry_foursquare
  puts entry_yelp
end
