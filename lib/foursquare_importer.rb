require 'dotenv'
require 'foursquare2'
require 'byebug'
require_relative 'contentful/restaurant'

Dotenv.load

def foursquare_credentials
  {
    client_id: ENV['FOURSQUARE_CLIENT_ID'],
    client_secret: ENV['FOURSQUARE_CLIENT_SECRET']
  }
end

def api_version
  ENV['FOURSQUARE_VERSION']
end


client = Foursquare2::Client.new(foursquare_credentials)

location = '52.502044,13.411283'
restaurant_name = 'Mustafas'

results = client.search_venues(ll: location, query: restaurant_name, v: api_version)

venues = results[:venues]

if venues.empty?
  puts "No venues found for restaurant: #{restaurant_name} (#{location})"
else
  venue = venues.first
  puts venue.to_hash
  venue_details = client.venue(venue[:id], v: api_version)
  contentful_restaurant = Contentful::Restaurant.new(contentful_id: 1, ratings: { foursquare: venue_details[:rating] })
end
