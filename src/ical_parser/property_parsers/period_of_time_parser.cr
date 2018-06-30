module IcalParser
  class PeriodOfTimeParser < ValueParser(PeriodOfTime)
    def parse(string : String, params = {} of String => String, options = [] of EventParser::Option) : T
      parts = string.split("/")
      if parts.size == 2
        if parts[1].match(DateTimeParser::DT_UTC_REGEX) || parts[1].match(DateTimeParser::DT_FLOATING_REGEX)
          start_time = DateTimeParser.parser.parse(parts[0])
          end_time = DateTimeParser.parser.parse(parts[1])
          PeriodOfTime.new(start_time, end_time)
        elsif parts[1].match(DurationParser::DAYS_REGEX) || parts[1].match(DurationParser::WEEKS_REGEX)
          start_time = DateTimeParser.parser.parse(parts[0])
          duration = DurationParser.parser.parse(parts[1])
          PeriodOfTime.new(start_time, duration)
        else
          raise "Invalid Period of Time format"
        end
      else
        raise "Invalid Period of Time format"
      end
    end
  end
end
