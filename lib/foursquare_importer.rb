require 'dotenv'
require 'foursquare2'
require_relative 'contentful/restaurant'

Dotenv.load

class FoursquareImporter

  def self.find(contentful_id = 1, location = '52.502044,13.411283', query = 'Mustafas')
    client = Foursquare2::Client.new(foursquare_credentials)
    results = client.search_venues(ll: location, query: query, v: api_version)
    venues = results[:venues]

    if venues.empty?
      puts "No venues found for restaurant: #{query} (#{location})"
    else
      venue = venues.first
      venue_details = client.venue(venue[:id], v: api_version)
      contentful_restaurant = Contentful::Restaurant.new(
        contentful_id: contentful_id,
        ratings: { foursquare: venue_details[:rating].round.to_f / 2 } # make rating out of 5 instead of 10
      )
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
