require "./date_time_parser"
require "./duration_parser"
require "./../period_of_time"

module IcalParser
  @@period_parser = Proc(String, Hash(String, String), String).new do |value, params|
    params = Hash(String, String).new

    parts = value.split("/")
    if parts.size == 2
      if parts[1].match(DT_UTC_REGEX) || parts[1].match(DT_FLOATING_REGEX)
        start_time = @@date_time_parser.call(parts[0], params)
        end_time = @@date_time_parser.call(parts[1], params)
        # PeriodOfTime.new(start_time, end_time)
        %({"start":#{start_time},"end":#{end_time}})
      elsif parts[1].match(DUR_DATE_REGEX) || parts[1].match(DUR_WEEKS_REGEX)
        start_time = @@date_time_parser.call(parts[0], params)
        duration = @@duration_parser.call(parts[1], params)
        # PeriodOfTime.new(start_time, duration)
        %({"start":#{start_time},"duration":#{duration}})
      else
        raise "Invalid Period of Time format"
      end
    else
      raise "Invalid Period of Time format"
    end
  end
end
