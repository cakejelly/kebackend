require 'dotenv'
require 'foursquare2'
require 'byebug'
require_relative 'contentful/restaurant'

Dotenv.load

class FoursquareImporter

  def self.find(location = '52.502044,13.411283', query = 'Mustafas')
    client = Foursquare2::Client.new(foursquare_credentials)

    results = client.search_venues(ll: location, query: query, v: api_version)

    venues = results[:venues]

    if venues.empty?
      puts "No venues found for restaurant: #{query} (#{location})"
    else
      venue = venues.first
      puts venue.to_hash
      venue_details = client.venue(venue[:id], v: api_version)
      contentful_restaurant = Contentful::Restaurant.new(contentful_id: 1, ratings: { foursquare: venue_details[:rating] })
    end
  end

  private

  def self.foursquare_credentials
    {
      client_id: ENV['FOURSQUARE_CLIENT_ID'],
      client_secret: ENV['FOURSQUARE_CLIENT_SECRET']
    }
  end

  def self.api_version
    ENV['FOURSQUARE_VERSION']
  end
end
