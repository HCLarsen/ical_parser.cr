require "uri"

require "./value_parser"

module IcalParser
  class URIParser < ValueParser
    def parse(string : String) : URI
      URI.parse(string)
    end
  end
end
