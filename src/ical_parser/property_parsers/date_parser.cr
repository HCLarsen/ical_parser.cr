require "./value_parser"

module IcalParser
  class DateParser < ValueParser
    DATE = Time::Format.new("%Y%m%d")

    def parse(string : String, params = {} of String => String) : Time
      if params["kind"]? == "Local"
        kind = Time::Kind::Local
      elsif params["kind"]? == "Utc"
        kind = Time::Kind::Utc
      else
        kind = Time::Kind::Unspecified
      end

      Time.parse(string, DATE.pattern, kind)
    end
  end
end
