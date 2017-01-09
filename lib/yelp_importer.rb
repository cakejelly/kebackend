require 'dotenv'
require 'yelp'
require 'byebug'
require_relative 'contentful/restaurant'

Dotenv.load

class YelpImporter

  def self.find(contentful_id = 1, location = '52.502044,13.411283', query = 'Mustafas')
    client = Yelp::Client.new(yelp_credentials)
    lat_lng = location.split(',')
    coordinates = { latitude: lat_lng[0], longitude: lat_lng[1] }
    params = { term: query, limit: 1 }
    locale = { lang: 'en' }
    result = client.search_by_coordinates(coordinates, params, locale)

    if result.businesses.empty?
      puts "No venues found for restaurant: #{query} (#{location})"
    else
      venue = result.businesses.first
      contentful_restaurant = Contentful::Restaurant.new(
        contentful_id: contentful_id,
        ratings: { yelp: venue.rating }
      )
    end
  end

  private

  def self.yelp_credentials
    {
      consumer_key: ENV['YELP_CONSUMER_KEY'],
      consumer_secret: ENV['YELP_CONSUMER_SECRET'],
      token: ENV['YELP_TOKEN'],
      token_secret: ENV['YELP_TOKEN_SECRET']
    }
  end
end
