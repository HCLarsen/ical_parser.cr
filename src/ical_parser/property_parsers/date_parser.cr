require "./value_parser"

module IcalParser
  class DateParser < ValueParser(Time)
    DATE       = Time::Format.new("%Y%m%d")
    DATE_REGEX = /^\d{8}$/

    def parse(string : String, params = {} of String => String, options = {} of String => Bool) : T
      if DATE_REGEX.match(string)
        if tz = params["TZID"]?
          location = Time::Location.load(tz)
        else
          location = Time::Location.local
        end

        begin
          Time.parse(string, DATE.pattern, location)
        rescue
          raise "Invalid Date"
        end
      else
        raise "Invalid Date format"
      end
    end
  end
end
