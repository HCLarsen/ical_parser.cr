module IcalParser
  class TimeParser < ValueParser
    TIME = Time::Format.new("%H%M%S")
    UTC_TIME = Time::Format.new("%H%M%SZ")

    DT_FLOATING_REGEX = /^\d{6}$/
    DT_UTC_REGEX = /^\d{6}Z$/

    def parse(string : String)
      if DT_FLOATING_REGEX.match(string)
        Time.parse(string, TIME.pattern, Time::Kind::Unspecified)
      elsif DT_UTC_REGEX.match(string)
        Time.parse(string, UTC_TIME.pattern, Time::Kind::Utc)
      else
        raise "Invalid Time format"
      end
    end
  end
end
