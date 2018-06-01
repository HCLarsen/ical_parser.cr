require "./value_parser"

module IcalParser
  class DateParser < ValueParser
    DATE = Time::Format.new("%Y%m%d")
    DATE_REGEX = /^\d{8}$/

    def parse(string : String, params = {} of String => String) : Time
      if DATE_REGEX.match(string)
        if params["kind"]? == "Local"
          kind = Time::Kind::Local
        elsif params["kind"]? == "Utc"
          kind = Time::Kind::Utc
        else
          kind = Time::Kind::Unspecified
        end

        begin
          Time.parse(string, DATE.pattern, kind)
        rescue
          raise "Invalid Date"
        end
      else
        raise "Invalid Date format"
      end
    end
  end
end
