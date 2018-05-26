require "uri"

module IcalParser
  module URIParser
    def self.parse(string)
      URI.parse(string)
    end
  end
end
