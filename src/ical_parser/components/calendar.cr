require "./event"
require "./../property_parsers/*"

module IcalParser
  class Calendar
    PROPERTIES = {
      "prodid"    => String,
      "version"   => String,
      "method"    => String,
      "calscale"  => String
    }

    JSON.mapping(
      prodid: {type: String},
      version: {type: String},
      method: {type: String?},
      calscale: {type: String?},
      events: {type: Array(Event)?}
    )

    property version = "2.0"

    def initialize(@prodid : String, @events = [] of Event)
    end

    def events
      @events || [] of Event
    end
  end
end
