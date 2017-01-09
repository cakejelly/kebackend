require 'json'
require 'sinatra'
require 'contentful/management'

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
  puts '*' * 32
  puts entity_name
  puts '*' * 32

  # Needed to update / enrich the entry later
  entry_id = content['sys']['id']

  #puts "LatLong #{lat_long}, Name #{entity_name}, EntryID #{entry_id} "
  {
    location: lat_long,
    entity_name: entity_name,
    entry_id: entry_id
  }
end

def fetch_sources(enrich_params)
  entry_foursquare = FoursquareImporter.find(
    enrich_params[:entry_id],
    enrich_params[:location],
    enrich_params[:entity_name])
  entry_yelp = YelpImporter.find(
    enrich_params[:entry_id],
    enrich_params[:location],
    enrich_params[:entity_name])

  # Debugging
  puts entry_foursquare
  puts entry_yelp

  {
    foursquare: entry_foursquare,
    yelp: entry_yelp
  }
end

def calculate_rating(foursquare, yelp)
  return yelp unless foursquare
  return foursquare unless yelp

  (foursquare + yelp) / 2
end

post '/kebabfetcher' do
  request.body.rewind  # in case someone already read it
  data = JSON.parse request.body.read
  puts JSON.pretty_generate(data)
  enrich_params = extract_params(data)

  # Enrich data
  enriched_entry = fetch_sources(enrich_params)
  foursquare = enriched_entry[:foursquare]
  yelp = enriched_entry[:yelp]
  puts enriched_entry

  rating = calculate_rating(foursquare[:ratings][:foursquare], yelp[:ratings][:yelp]).round

  restaurant = fetch_restaurant(enrich_params[:entry_id])
  restaurant.rating = rating
  restaurant.address = foursquare[:address]
  restaurant.website = foursquare[:website]
  restaurant.tags = foursquare[:tags]
  restaurant.pictures_list = foursquare[:photo_urls]
  restaurant.save
  restaurant.publish
end

def fetch_restaurant(restaurant_id)
  @restuarant ||= kebabful_space.entries.find(restaurant_id)
end

def kebabful_space
  @space ||= contentful_client.spaces.find(ENV['CONTENTFUL_SPACE_ID'])
end

def contentful_client
  @contentful ||= Contentful::Management::Client.new(ENV['CONTENTFUL_ACCESS_TOKEN'])
end
