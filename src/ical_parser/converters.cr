module JSON::ArrayConverter(Converter)
  def self.from_json(pull : JSON::PullParser)
    ary = Array(typeof(Converter.from_json(pull))).new
    pull.read_array do
      ary << Converter.from_json(pull)
    end
    ary
  end

  def self.to_json(values : Array, builder : JSON::Builder)
    builder.array do
      values.each do |value|
        Converter.to_json(value, builder)
      end
    end
  end
end

struct Time
  module ISO8601Converter
    ISO8601_UTC_DT_REGEX = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/
    ISO8601_TZ_DT_REGEX = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}-\d{2}:\d{2}/
    TZ_REGEX = /\w+\/\w+$/

    def self.from_json(value : JSON::PullParser) : Time
      string = value.read_string
      if string.match(ISO8601_UTC_DT_REGEX)
        Time::Format::ISO_8601_DATE_TIME.parse(string)
      elsif string.match(ISO8601_TZ_DT_REGEX)
        Time.parse_local(string, "%FT%T%:z")
      else
        Time::Format::ISO_8601_DATE.parse(string)
      end
    end

    def self.to_json(value : Time, json : JSON::Builder)
      Time::Format::ISO_8601_DATE_TIME.format(value).to_json(json)
    end
  end
end

class URI
  module URIConverter
    def self.from_json(value : JSON::PullParser) : URI
      URI.parse(value.read_string)
    end

    def self.to_json(value : URI, json : JSON::Builder)
      value.to_s.to_json(json)
    end
  end
end

module IcalParser
  struct RecurrenceRule
    module ByDayConverter
      def self.from_json(value : JSON::PullParser) : Array({Int32, Time::DayOfWeek})
        byday_regex = /(?<num>-?[1-9]?)(?<day>[A-Z]{2})/
        output = [] of {Int32, Time::DayOfWeek}
        value.read_array do
          day = value.read_string
          if match = day.match(byday_regex)
            num = match["num"].empty? ? 0 : match["num"].to_i
            output << {num, RecurrenceRule.weekday_to_day_of_week(match["day"])}
          else
            raise "Invalid BYDAY rule format"
          end
        end
        output
      end

      def self.to_json(value : Array({Int32, Time::DayOfWeek}), json : JSON::Builder)
        value.map do |day|
          output = day[0] > 0 ? day[0].to_s : ""
          output + day[1].to_s[0..1].upcase
        end.to_json(json)
      end
    end

    module DayOfWeekConverter
      def self.from_json(value : JSON::PullParser) : Time::DayOfWeek
        RecurrenceRule.weekday_to_day_of_week(value.read_string)
      end

      def self.to_json(value : Time::DayOfWeek, json : JSON::Builder)
        value.to_s[0..1].upcase.to_json(json)
      end
    end

    protected def self.weekday_to_day_of_week(day : String) : Time::DayOfWeek
      case day
      when "MO"
        Time::DayOfWeek::Monday
      when "TU"
        Time::DayOfWeek::Tuesday
      when "WE"
        Time::DayOfWeek::Wednesday
      when "TH"
        Time::DayOfWeek::Thursday
      when "FR"
        Time::DayOfWeek::Friday
      when "SA"
        Time::DayOfWeek::Saturday
      when "SU"
        Time::DayOfWeek::Sunday
      else
        raise "Invalid Day of Week value: #{day}"
      end
    end
  end
end
