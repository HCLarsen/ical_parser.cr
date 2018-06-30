require "uri"

require "./value_parser"

module IcalParser
  class URIParser < ValueParser(URI)
    def parse(string : String, params = {} of String => String, options = [] of EventParser::Option) : T
      URI.parse(string)
    end
  end
end
