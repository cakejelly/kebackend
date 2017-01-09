require_relative '../keyword_struct'

module Contentful
  class Restaurant < KeywordStruct.new(:contentful_id, :ratings, :address, :website, :tags, :photo_urls)

  end
end
