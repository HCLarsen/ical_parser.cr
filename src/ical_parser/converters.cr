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
