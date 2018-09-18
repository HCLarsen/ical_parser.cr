require "./value_parser"

module IcalParser
  class DateParser < ValueParser(Time)

    def parse(string : String, params = {} of String => String) : T
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

  @@date_parser = Proc(String, Hash(String, String), Time).new do |value, params|
    if DATE_REGEX.match(value)
      if tz = params["TZID"]?
        location = Time::Location.load(tz)
      else
        location = Time::Location.local
      end

      begin
        Time.parse(value, DATE.pattern, location)
      rescue
        raise "Invalid Date"
      end
    else
      raise "Invalid Date format"
    end
  end
end
