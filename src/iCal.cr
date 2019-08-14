require "json"
require "./ical_parser/*"
require "./ical_parser/components/*"
require "./ical_parser/component_parsers/*"
require "./ical_parser/property_parsers/*"
require "./ical_parser/stream_parser/*"

# TODO: Write documentation for `IcalParser`
module IcalParser
  alias ParserType = Proc(String, Hash(String, String), String)

  PARSERS = {
    "BINARY"      => @@text_parser,  # To be replaced with BinaryParser once written.
    "BOOLEAN"     => @@boolean_parser,
    "CAL-ADDRESS" => @@caladdress_parser,
    "DATE"        => @@date_parser,
    "DATE-TIME"   => @@date_time_parser,
    "DURATION"    => @@duration_parser,
    "FLOAT"       => @@float_parser,
    "INTEGER"     => @@integer_parser,
    "PERIOD"      => @@period_parser,
    "RECUR"       => @@recurrence_parser,
    "TEXT"        => @@text_parser,
    "TIME"        => @@time_parser,
    "URI"         => @@uri_parser,
    "UTC-OFFSET"  => @@text_parser,  # To be replaced with UTCOffsetParser once written.
  }

  COMPONENT_PROPERTIES = {
    uid: {types: ["TEXT"], required: true},
    dtstamp: {types: ["DATE-TIME"], required: true},
    created: {types: ["DATE-TIME"]},
    last_mod: {types: ["DATE-TIME"], key: "last-mod"},
    dtstart: {types: ["DATE-TIME", "DATE"], required: true},
    dtend: {types: ["DATE-TIME", "DATE"]},
    duration: {types: ["DURATION"]},
    summary: {types: ["TEXT"]},
    classification: {types: ["TEXT"], default: "public"},
    categories: {types: ["TEXT"], list: true},
    resources: {types: ["TEXT"], list: true},
    contacts: {types: ["TEXT"]},
    related_to: {types: ["TEXT"], key: "related-to", getter: false},
    request_status: {types: ["TEXT"], key: "request-status", getter: false},
    transparency: {types: ["TEXT"], default: "opaque"},
    description: {types: ["TEXT"]},
    status: {types: ["TEXT"]},
    comments: {types: ["TEXT"]},
    location: {types: ["TEXT"]},
    priority: {types: ["INTEGER"]},
    sequence: {types: ["INTEGER"]},
    organizer: {types: ["CAL-ADDRESS"]},
    attendees: {types: ["CAL-ADDRESS"]},
    geo: {types: ["FLOAT"]},
    recurrence: {types: ["RECUR"]},
    exdate: {types: ["DATE-TIME", "DATE"], list: true},
    rdate: {types: ["DATE-TIME", "DATE", "PERIOD"], list: true},
    url: {types: ["URI"], converter: URI::URIConverter},
    all_day: {types: ["BOOLEAN"], key: "all-day"}
  }
end
