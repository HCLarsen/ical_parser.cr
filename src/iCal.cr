require "./ical_parser/*"
require "./ical_parser/components/*"
require "./ical_parser/component_parsers/*"
require "./ical_parser/property_parsers/*"

# TODO: Write documentation for `IcalParser`
module IcalParser
  TYPES = [Bool, CalAddress, Float64, Int32, PeriodOfTime, RecurrenceRule, String, Time, Time::Span, URI]

  {% begin %}
    alias ValueType = {{ TYPES.join(" | ").id }}
    {% arrays = TYPES.map{|e| "Array(#{e})".id } %}
    alias ValueArray = {{ arrays.join(" | ").id }}
    {% hashes = TYPES.map{|e| "Hash(String, #{e})".id } %}
    alias ValueHash = {{ hashes.join(" | ").id }}

    alias ParserType = {{ TYPES.map{|e| "Proc(String, Hash(String, String), #{e})".id}.join(" | ").id }}

    alias PropertyType = ValueType | ValueArray | ValueHash
  {% end %}

  PARSERS = {
    "BINARY"      => TextParser.parser,  # To be replaced with BinaryParser once written.
    "BOOLEAN"     => BooleanParser.parser,
    "CAL-ADDRESS" => CalAddressParser.parser,
    "DATE"        => DateParser.parser,
    "DATE-TIME"   => DateTimeParser.parser,
    "DURATION"    => DurationParser.parser,
    "FLOAT"       => FloatParser.parser,
    "INTEGER"     => IntegerParser.parser,
    "PERIOD"      => PeriodOfTimeParser.parser,
    "RECUR"       => RecurrenceRuleParser.parser,
    "TEXT"        => TextParser.parser,
    "TIME"        => TimeParser.parser,
    "URI"         =>  URIParser.parser,
    "UTC-OFFSET"  => TextParser.parser,  # To be replaced with UTCOffsetParser once written.
  }
end
