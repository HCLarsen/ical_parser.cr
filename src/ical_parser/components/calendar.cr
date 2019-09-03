require "./../property_parsers/*"
require "./../property"
require "./../enums"
require "./*"

module IcalParser
  class Calendar
    PROPERTIES = {
      "prodid"    => Property.new("prodid"),
      "version"   => Property.new("version"),
      "calscale"  => Property.new("calscale"),
      "method"    => Property.new("method"),
    }

    JSON.mapping(
      prodid: {type: String},
      version: {type: String},
      method: {type: String?},
      calscale: {type: String?},
      events: {type: Array(Event)?}
    )

    @version = "2.0"
    getter events, type: Array(Event), value: [] of Event

    def initialize(@prodid : String, @events = [] of Event)
    end
  end
end
