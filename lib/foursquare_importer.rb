require 'dotenv'
require 'foursquare2'
require_relative 'contentful/restaurant'

class FoursquareImporter

  def self.extract_photo_urls(photos)
    photos.map {|photo| build_url(photo) }.first(6)
  end

  def self.build_url(photo)
    "#{photo.prefix}300x300#{photo.suffix}"
  end

  def self.find(contentful_id = 1, location = '52.502044,13.411283', query = 'Mustafas')
    client = Foursquare2::Client.new(foursquare_credentials)
    results = client.search_venues(ll: location, query: query, v: api_version)
    venues = results[:venues]

    if venues.empty?
      puts "No venues found for restaurant: #{query} (#{location})"
    else
      venue = venues.first
      venue_details = client.venue(venue[:id], v: api_version)
      address = if venue_details[:location] && venue_details[:location][:formattedAddress]
                  venue_details[:location][:formattedAddress].join("\n")
                else
                  nil
                end

      tags = venue_details[:tags].nil? ? nil : venue_details[:tags].join(', ')
      rating = venue_details[:rating].nil? ? nil : venue_details[:rating].round.to_f / 2
      photos = venue_details.photos.groups.first.items
      photo_urls = extract_photo_urls(photos)

      contentful_restaurant = Contentful::Restaurant.new(
        contentful_id: contentful_id,
        ratings: { foursquare: rating }, # make rating out of 5 instead of 10
        address: address,
        website:  venue_details[:url],
        tags: tags,
        photo_urls: photo_urls
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
