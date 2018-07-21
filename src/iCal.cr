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
    alias PropertyType = ValueType | ValueArray | NamedTuple(lat: Float64, lon: Float64)
  end

  create_aliases
end
