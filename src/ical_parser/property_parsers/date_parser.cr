require "./value_parser"

module IcalParser
  class DateParser < ValueParser
    DATE = Time::Format.new("%Y%m%d")

    def parse(string : String) : Time
      Time.parse(string, DATE.pattern)
    end
  end
end
