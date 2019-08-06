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
    "uid"             => Property.new("TEXT"),
    "dtstamp"         => Property.new("DATE-TIME"),
    "created"         => Property.new("DATE-TIME"),
    "last-mod"        => Property.new("DATE-TIME"),
    "dtstart"         => Property.new("DATE-TIME", alt_values: ["DATE"]),
    "dtend"           => Property.new("DATE-TIME", alt_values: ["DATE"]),
    "duration"        => Property.new("DURATION"),
    "summary"         => Property.new("TEXT"),
    "description"     => Property.new("TEXT"),
    "classification"  => Property.new("TEXT"),
    "categories"      => Property.new("TEXT", single_value: false, only_once: false),
    "resources"       => Property.new("TEXT", single_value: false, only_once: false),
    "contacts"        => Property.new("TEXT", single_value: false, only_once: false),
    "related_to"      => Property.new("TEXT", single_value: false, only_once: false),
    "request-status"  => Property.new("TEXT", only_once: false),
    "transp"          => Property.new("TEXT"),
    "status"          => Property.new("TEXT"),
    "comments"        => Property.new("TEXT"),
    "location"        => Property.new("TEXT"),
    "priority"        => Property.new("INTEGER"),
    "sequence"        => Property.new("INTEGER"),
    "organizer"       => Property.new("CAL-ADDRESS"),
    "attendees"       => Property.new("CAL-ADDRESS", only_once: false),
    "geo"             => Property.new("FLOAT", parts: ["lat", "lon"]),
    "recurrence"      => Property.new("RECUR"),
    "exdate"          => Property.new("DATE-TIME", alt_values: ["DATE"], single_value: false, only_once: false),
    "rdate"           => Property.new("DATE-TIME", alt_values: ["DATE", "PERIOD"], single_value: false, only_once: false),
    "url"             => Property.new("URI"),
  }
end
