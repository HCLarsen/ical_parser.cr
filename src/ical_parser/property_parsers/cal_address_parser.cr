require "uri"

module IcalParser
  class CalAddressParser < ValueParser
    def parse(string : String, params = {} of String => String) : CalAddress
      uri = URI.parse(string)
      CalAddress.new(uri, params)
    end
  end
end
