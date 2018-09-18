require "./date_parser"
require "./time_parser"

module IcalParser
  class DateTimeParser < ValueParser(Time)
    # FLOATING_DATE_TIME = Time::Format.new("%Y%m%dT%H%M%S")
    # UTC_DATE_TIME      = Time::Format.new("%Y%m%dT%H%M%SZ")
    #
    # DT_FLOATING_REGEX = /^\d{8}T\d{6}$/
    # DT_UTC_REGEX      = /^\d{8}T\d{6}Z$/
    #
    def parse(string : String, params = {} of String => String) : T
      if params["VALUE"]? != "DATE"
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
      else
        DateParser.parser.parse(string, params)
      end
    end
  end

  @@date_parser = Proc(String, Hash(String, String), Time).new do |value, params|
    if params["VALUE"]? != "DATE"
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
    else
      DateParser.parser.parse(value, params)
    end
  end
end
