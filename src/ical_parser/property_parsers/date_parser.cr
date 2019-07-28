require "json"

module IcalParser
  @@date_parser = Proc(String, Hash(String, String), String).new do |value, params|
    if DATE_REGEX.match(value)
      begin
        Time.parse(value, DATE.pattern, Time::Location.local).to_s("%F").to_json
      rescue
        raise "Invalid Date"
      end
    else
      raise "Invalid Date format"
    end
  end
end
