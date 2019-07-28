require "./../duration"

module IcalParser
  @@duration_parser = Proc(String, Hash(String, String), String).new do |value, params|
    if match = value.match(DUR_DATE_REGEX)
      captures = get_captures(match)
      duration = Duration.new(days: captures["days"]?, hours: captures["hours"]?, minutes: captures["minutes"]?, seconds: captures["seconds"]?).to_json
    elsif match = value.match(DUR_WEEKS_REGEX)
      days = match["weeks"].to_i * 7
      duration = Duration.new(match["weeks"].to_i).to_json
    else
      raise "Invalid Duration format"
    end
  end

  private def self.get_captures(match : Regex::MatchData) : Hash(String, Int32?)
    sign = match["polarity"]?  == "-" ? -1 : 1
    captures = {} of String => Int32?
    match.named_captures.compact.each do |k, v|
      captures[k] = v.to_i { 0 } * sign
    end
    captures
  end
end
