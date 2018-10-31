require "./value_parser"

module IcalParser
  @@duration_parser = Proc(String, Hash(String, String), Time::Span).new do |value, params|
    if match = value.match(DUR_DATE_REGEX)
      captures = get_captures(match)
      duration = Time::Span.new(captures["days"], captures["hours"], captures["minutes"], captures["seconds"])
    elsif match = value.match(DUR_WEEKS_REGEX)
      days = match["weeks"].to_i * 7
      duration = Time::Span.new(days, 0, 0, 0)
    else
      raise "Invalid Duration format"
    end
    match["polarity"]? == "-" ? duration * -1 : duration
  end

  private def self.get_captures(match : Regex::MatchData) : Hash(String, Int32)
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
