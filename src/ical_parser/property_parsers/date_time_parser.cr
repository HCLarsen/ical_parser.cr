require "./date_parser"
require "./time_parser"

module IcalParser
  @@date_time_parser = Proc(String, Hash(String, String), Time).new do |value, params|
    begin
      date_string, time_string = value.split('T')
    rescue
      raise "Invalid Date-Time format"
    end
    raise "Invalid Date-Time format" if date_string.empty? || time_string.empty?
    time = @@time_parser.call(time_string, params)
    params["TZID"] ||= time.location.to_s
    date = @@date_parser.call(date_string, params)
    date + time.time_of_day
  end
end
