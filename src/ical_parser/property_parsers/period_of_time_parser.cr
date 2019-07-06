require "./date_time_parser"
require "./duration_parser"

module IcalParser
  @@period_parser = Proc(String, Hash(String, String)).new do |value|
    parts = value.split("/")
    if parts.size == 2
      if parts[1].match(DT_UTC_REGEX) || parts[1].match(DT_FLOATING_REGEX)
        start_time = @@date_time_parser.call(parts[0])
        end_time = @@date_time_parser.call(parts[1])
        {"start" => start_time, "finish" => end_time}
      elsif parts[1].match(DUR_DATE_REGEX) || parts[1].match(DUR_WEEKS_REGEX)
        start_time = @@date_time_parser.call(parts[0])
        duration = @@duration_parser.call(parts[1])
        {"start" => start_time, "duration" => duration}
      else
        raise "Invalid Period of Time format"
      end
    else
      raise "Invalid Period of Time format"
    end
  end
end
