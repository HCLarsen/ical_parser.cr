require "uri"

module IcalParser
  class CalAddressParser < ValueParser(CalAddress)
    def parse(string : String, params = {} of String => String) : T
      uri = URI.parse(string)
      CalAddress.new(uri)
    end
  end
end
