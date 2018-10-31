module IcalParser
  # The TimeParser singleton class parses the RFC5545 [Time](https://tools.ietf.org/html/rfc5545#section-3.3.12) value type
  #
  # As a singleton class, typical instantiation will result in a compile
  # time error.
  #
  # ```
  # TimeParser.new # => private method 'new' called for IcalParser::TimeParser:Class
  # ```
  #
  # Instead, access the singleton instance by calling #parser on the class.
  #
  # ```
  # parser = TimeParser.parser # => #<IcalParser::TimeParser:0x1062d0f60>
  # ```
  #
  # NOTE: The Time parser does not take time zone information into account,
  # despite the RFC specification listing it as a form for Time values.
  # This is due to the impact of Daylight Savings Time, which makes it
  # impossible to determine the offset of a time zone without knowing the date.
  # Time zone information is instead parsed and set by the Date-Time parser.
  @@time_parser = Proc(String, Hash(String, String), Time).new do |value, params|
    if TIME_FLOATING_REGEX.match(value)
      if tz = params["TZID"]?
        location = Time::Location.load(tz)
      else
        location = Time::Location.local
      end
      Time.parse(value, TIME.pattern, location)
    elsif TIME_UTC_REGEX.match(value)
      Time.parse(value, UTC_TIME.pattern, Time::Location::UTC)
    else
      raise "Invalid Time format"
    end
  end
end
