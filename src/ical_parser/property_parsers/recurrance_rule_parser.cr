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
      hash = {} of String => Array(String)
      pairs = string.split(';')
      pairs.each do  |pair|
        name, value = pair.split('=').map(&.downcase)
        hash[name] = value.split(',')
      end

      frequency = RecurrenceRule::Freq.from_string(hash["freq"].first)
      interval = hash["interval"]? ? hash["interval"].first.to_i : 1

      if hash["until"]?
        until_string = hash["until"].first.upcase
        end_time = DateTimeParser.parser.parse(until_string)
        RecurrenceRule.new(frequency, end_time: end_time, interval: interval)
      elsif hash["count"]?
        count = hash["count"].first.to_i
        RecurrenceRule.new(frequency, count: count, interval: interval)
      else
        RecurrenceRule.new(frequency, interval: interval)
      end
    end
  end
end
