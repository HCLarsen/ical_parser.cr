require "./date_parser"
require "./time_parser"

module IcalParser
  @@date_time_parser = Proc(String, String).new do |value|
    if DT_FLOATING_REGEX.match(value) || DT_UTC_REGEX.match(value)
      value
    else
      raise "Invalid Date-Time format"
    end
  end
end
