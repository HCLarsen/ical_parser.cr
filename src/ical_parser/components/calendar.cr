require "./../property_parsers/*"
require "./../property"
require "./../enums"
require "./*"

module IcalParser
  class Calendar
    PROPERTIES = {
      "prodid"    => { name: "prodid", required: true },
      "version"   => { name: "version", required: true },
      "calscale"  => { name: "calscale" },
      "method"    => { name: "method" },
    }

    COMPONENTS = {
      "VEVENT"    => {parser: EventParser, key: "events"},
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
