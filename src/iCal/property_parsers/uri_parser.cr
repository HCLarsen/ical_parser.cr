require "uri"

module ICal
  module URIParser
    def self.parse(string)
      URI.parse(string)
    end
  end
end
