module IcalParser
  # The time_parser function parses the RFC5545 [Time](https://tools.ietf.org/html/rfc5545#section-3.3.12) value type and returns the number of seconds since the [Epoch](https://en.wikipedia.org/wiki/Unix_time) in seconds.
  #
  # @@time_parser.call("230000", Hash(String, String).new) #=> 100800
  @@time_parser = Proc(String, String).new do |value|
    if TIME_FLOATING_REGEX.match(value)
      value
      # if tz = params["TZID"]?
      #   location = Time::Location.load(tz)
      # else
      #   location = Time::Location.local
      # end
      # Time.parse(value, TIME.pattern, location)
    elsif TIME_UTC_REGEX.match(value)
      value
    else
      raise "Invalid Time format"
    end
  end
end
