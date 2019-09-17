require "./../enums"
require "./*"

module IcalParser
  class Calendar < Component
    PROPERTIES = {
      "prodid"    => { name: "prodid", required: true },
      "version"   => { name: "version", required: true },
      "calscale"  => { name: "calscale" },
      "method"    => { name: "method" },
    }

    COMPONENTS = {
      "VEVENT"    => {parser: EventParser, class: Event, key: "events"},
    }

    mapping

    @version = "2.0"
    getter events, type: Array(Event), value: [] of Event

    def initialize(@prodid : String, @events = [] of Event)
    end
  end
end
