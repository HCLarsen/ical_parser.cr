require "uri"

require "./value_parser"

module IcalParser
  class URIParser < ValueParser(URI)
    def parse(string : String, params = {} of String => String, options = {} of String => Bool) : T
      URI.parse(string)
    end
  end
end
