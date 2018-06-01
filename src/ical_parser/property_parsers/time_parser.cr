module IcalParser
  # Parser for the [Time](https://tools.ietf.org/html/rfc5545#section-3.3.12) value type
  #
  # > Note: The Time parser does not take time zone information into account,
  # despite the RFC specification listing it as a form for Time values.
  # This is due to the impact of Daylight Savings Time, which makes it
  # impossible to determine the offset of a time zone without knowing the date.
  # Time zone information is instead parsed and set by the Date-Time parser.
  #
  class TimeParser < ValueParser
    TIME = Time::Format.new("%H%M%S")
    UTC_TIME = Time::Format.new("%H%M%SZ")

    DT_FLOATING_REGEX = /^\d{6}$/
    DT_UTC_REGEX = /^\d{6}Z$/

    # Parses the Time value and returns it as a Crystal Time object.
    #
    def parse(string : String, params = {} of String => String)
      if DT_FLOATING_REGEX.match(string)
        Time.parse(string, TIME.pattern, Time::Kind::Unspecified)
      elsif DT_UTC_REGEX.match(string)
        Time.parse(string, UTC_TIME.pattern, Time::Kind::Utc)
      else
        raise "Invalid Time format"
      end
    end
  end
end
