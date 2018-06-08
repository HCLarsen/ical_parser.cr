require "./date_parser"
require "./time_parser"

module IcalParser
  class DateTimeParser < ValueParser(Time)
    FLOATING_DATE_TIME = Time::Format.new("%Y%m%dT%H%M%S")
    UTC_DATE_TIME = Time::Format.new("%Y%m%dT%H%M%SZ")

    DT_FLOATING_REGEX = /^\d{8}T\d{6}$/
    DT_UTC_REGEX = /^\d{8}T\d{6}Z$/

    def parse(string : String, params = {} of String => String) : T
      begin
        date_string, time_string = string.split('T')
      rescue
      	raise "Invalid Date-Time format"
      end
      raise "Invalid Date-Time format" if date_string == nil || time_string == nil
      time = TimeParser.parser.parse(time_string)
      date = DateParser.parser.parse(date_string, { "kind" => time.kind.to_s })
      date + time.time_of_day
    end
  end
end
