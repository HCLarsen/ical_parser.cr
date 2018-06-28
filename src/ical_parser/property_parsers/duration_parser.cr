require "./value_parser"

module IcalParser
  class DurationParser < ValueParser(Time::Span)
    DAYS_REGEX  = /^(?<polarity>[+-])?P((?<days>\d+)D)?(T((?<hours>\d+)H)?((?<minutes>\d+)M)?((?<seconds>\d+)S)?)?$/
    WEEKS_REGEX = /^(?<polarity>[+-])?P(?<weeks>\d+)W$/

    def parse(string : String, params = {} of String => String, options = {} of String => Bool) : T
      if match = string.match(DAYS_REGEX)
        captures = get_captures(match)
        duration = Time::Span.new(captures["days"], captures["hours"], captures["minutes"], captures["seconds"])
      elsif match = string.match(WEEKS_REGEX)
        days = match["weeks"].to_i * 7
        duration = Time::Span.new(days, 0, 0, 0)
      else
        raise "Invalid Duration format"
      end
      match["polarity"]? == "-" ? duration * -1 : duration
    end

    def get_captures(match : Regex::MatchData) : Hash(String, Int32)
      captures = {} of String => Int32
      match.named_captures.each do |k, v|
        if v.nil?
          captures[k] = 0
        else
          captures[k] = v.to_i { 0 }
        end
      end
      captures.compact
    end
  end
end
