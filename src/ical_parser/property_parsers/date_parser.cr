require "./value_parser"

module IcalParser
  @@date_parser = Proc(String, Hash(String, String), String).new do |value, params|
    if DATE_REGEX.match(value)
      # if tz = params["TZID"]?
      #   location = Time::Location.load(tz)
      # else
      #   location = Time::Location.local
      # end

      begin
        Time.parse(value, DATE.pattern, Time::Location.local)
      rescue
        raise "Invalid Date"
      end

      value
    else
      raise "Invalid Date format"
    end
  end
end
