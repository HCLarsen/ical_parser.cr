require "./ical_parser/*"
require "./ical_parser/components/*"
require "./ical_parser/component_parsers/*"
require "./ical_parser/property_parsers/*"

# TODO: Write documentation for `IcalParser`
module IcalParser
  alias ICalValue = Bool | CalAddress | Float64 | Int32 | PeriodOfTime | String | Time | Time::Span | URI | Array(Bool) | Array(CalAddress) | Array(Float64) | Array(Int32)| Array(PeriodOfTime) | Array(String) | Array(Time) | Array(Time::Span) | Array(URI)
end
