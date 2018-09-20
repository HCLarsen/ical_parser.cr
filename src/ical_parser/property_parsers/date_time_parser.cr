require "./date_parser"
require "./time_parser"

module IcalParser
  class DateTimeParser < ValueParser(Time)
    def parse(string : String, params = {} of String => String) : T
      begin
        date_string, time_string = string.split('T')
      rescue
        raise "Invalid Date-Time format"
      end
      raise "Invalid Date-Time format" if date_string.empty? || time_string.empty?
      time = TimeParser.parser.parse(time_string, params)
      params["TZID"] ||= time.location.to_s
      date = DateParser.parser.parse(date_string, params)
      date + time.time_of_day
    end
  end

  @@date_time_parser = Proc(String, Hash(String, String), Time).new do |value, params|
    begin
      date_string, time_string = value.split('T')
    rescue
      raise "Invalid Date-Time format"
    end
    raise "Invalid Date-Time format" if date_string.empty? || time_string.empty?
    time = TimeParser.parser.parse(time_string, params)
    params["TZID"] ||= time.location.to_s
    date = DateParser.parser.parse(date_string, params)
    date + time.time_of_day
  end
end
