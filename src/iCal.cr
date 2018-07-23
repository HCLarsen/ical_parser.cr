require "./ical_parser/*"
require "./ical_parser/components/*"
require "./ical_parser/component_parsers/*"
require "./ical_parser/property_parsers/*"

# TODO: Write documentation for `IcalParser`
module IcalParser
  macro create_aliases
    {% types = [Bool, CalAddress, Float64, Int32, PeriodOfTime, String, Time, Time::Span, URI] %}
    alias ValueType = {{ types.join(" | ").id }}
    {% arrays = types.map{|e| "Array(#{e})".id } %}
    alias ValueArray = {{ arrays.join(" | ").id }}
    {% hashes = types.map{|e| "Hash(String, #{e})".id } %}
    alias ValueHash = {{ hashes.join(" | ").id }}

    alias PropertyType = ValueType | ValueArray | ValueHash
  end

  create_aliases
end
