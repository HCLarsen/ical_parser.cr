require "json"
require "./date_parser"
require "./time_parser"

module IcalParser
  @@date_time_parser = Proc(String, Hash(String, String), String).new do |value, params|
    if DT_FLOATING_REGEX.match(value)
      pattern = DATE.pattern + "T" + TIME.pattern
      if tz = params["TZID"]?
        location = Time::Location.load(tz)
        output = "%FT%T%:z"
      else
        location = Time::Location.local
        output = "%FT%T"
      end
    elsif DT_UTC_REGEX.match(value)
      location = Time::Location::UTC
      pattern = DATE.pattern + "T" + UTC_TIME.pattern
      output = "%FT%TZ"
    else
      raise "Invalid Date-Time format"
    end

    date_time = Time.parse(value, pattern, location).to_s(output).to_json
  end
end
