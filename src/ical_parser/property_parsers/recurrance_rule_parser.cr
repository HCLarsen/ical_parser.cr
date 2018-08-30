module IcalParser
  # Parser for the Recurrence Rule property
  #
  # This class parses the Recurrence Rule property and produces an instance of
  # the RecurrenceRule class to be stored in an Event, Journal, To-Do, or
  # Time Zone definition object.
  #
  # ### Parsing
  #
  # parser = RecurrenceRule.parser
  # recur = parser.parse("FREQ=WEEKLY;UNTIL=19971007T000000Z;WKST=SU;BYDAY=TU,TH")
  # recur.frequency   #=> Weekly
  # recur.end_time    #=> 1997-10-07 00:00:00.0 UTC
  # recur.week_start  #=> Time::DayOfWeek::Sunday
  # recur.by_day      #=> [Time::DayOfWeek::Tuesday, Time::DayOfWeek::Thursday]
  class RecurrenceRuleParser < ValueParser(RecurrenceRule)
    def parse(string : String, params = {} of String => String) : T
      hash = {} of String => String
      pairs = string.split(';')
      pairs.each do  |pair|
        name, value = pair.split('=')
        hash[name.downcase] = value
      end

      frequency = RecurrenceRule::Freq.from_string(hash["freq"].downcase)
      interval = hash["interval"]? ? hash["interval"].to_i : 1

      rules = {} of String => RecurrenceRule::ByRuleType
      rules["by_month"] = hash["bymonth"].split(',').map(&.to_i) if hash["bymonth"]?
      if hash["byday"]?
        days = hash["byday"].split(',').map { |day| day_to_day_of_week(day)}
        rules["by_day"] = days.map { |day| {0, day} }
      end

      if hash["until"]?
        until_string = hash["until"].upcase
        end_time = DateTimeParser.parser.parse(until_string)
        RecurrenceRule.new(frequency, end_time: end_time, by_rules: rules, interval: interval)
      elsif hash["count"]?
        count = hash["count"].to_i
        RecurrenceRule.new(frequency, count: count, interval: interval)
      else
        RecurrenceRule.new(frequency, interval: interval)
      end
    end

    private def day_to_day_of_week(day : String) : Time::DayOfWeek
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
        raise "Invalid Day of Week value"
      end
    end
  end
end
