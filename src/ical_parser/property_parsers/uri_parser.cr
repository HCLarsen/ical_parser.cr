require "uri"

require "./value_parser"

module IcalParser
  class URIParser < ValueParser(URI)
    def parse(string : String, params = {} of String => String) : T
      URI.parse(string)
    end
  end
end
