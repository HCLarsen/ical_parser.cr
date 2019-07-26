require "json"
require "./ical_parser/*"
require "./ical_parser/components/*"
require "./ical_parser/component_parsers/*"
require "./ical_parser/property_parsers/*"
require "./ical_parser/stream_parser/*"

# TODO: Write documentation for `IcalParser`
module IcalParser
  TYPES = [Bool, Float64, Int32, String, Time]

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
end
