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

    alias PropertyType = ValueType | ValueArray | ValueHash
  {% end %}
end
