module IcalParser
  # The time_parser function parses the RFC5545 [Time](https://tools.ietf.org/html/rfc5545#section-3.3.12) value type and returns the number of seconds since the [Epoch](https://en.wikipedia.org/wiki/Unix_time) in seconds.
  #
  # @@time_parser.call("230000", Hash(String, String).new) #=> 100800
  @@time_parser = Proc(String, Hash(String, String), String).new do |value, params|
    if TIME_FLOATING_REGEX.match(value)
      if tz = params["TZID"]?
        location = Time::Location.load(tz)
        Time.parse(value, TIME.pattern, location).to_s("%T%:z")
      else
        location = Time::Location.local
        Time.parse(value, TIME.pattern, location).to_s("%T")
      end
    elsif TIME_UTC_REGEX.match(value)
      Time.parse(value, UTC_TIME.pattern, Time::Location::UTC).to_s("%TZ")
    else
      raise "Invalid Time format"
    end
  end
end
