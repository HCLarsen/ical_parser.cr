require "./ical_parser/*"
require "./ical_parser/components/*"
require "./ical_parser/component_parsers/*"
require "./ical_parser/property_parsers/*"

# TODO: Write documentation for `IcalParser`
module IcalParser
  alias ICalValue = Bool | CalAddress | Time | Time::Span | Float64 | Int32 | PeriodOfTime | String | Array(String) | URI
end
