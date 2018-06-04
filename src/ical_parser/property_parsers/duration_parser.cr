require "./value_parser"

module IcalParser
  class DurationParser < ValueParser
    def parse(string) : Time::Span
      days_regex = /^(?<polarity>[+-])?P((?<days>\d+)D)?(T((?<hours>\d+)H)?((?<minutes>\d+)M)?((?<seconds>\d+)S)?)?$/
      weeks_regex = /^(?<polarity>[+-])?P(?<weeks>\d+)W$/

      if match = string.match(days_regex)
        captures = get_captures(match)
        duration = Time::Span.new(captures["days"], captures["hours"], captures["minutes"], captures["seconds"])
      elsif match = string.match(weeks_regex)
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
