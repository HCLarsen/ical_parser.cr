module IcalParser
  # Parser for the Recurrance Rule property
  #
  # This class parses the Recurrance Rule property and produces an instance of
  # the RecurranceRule class to be stored in an Event, Journal, To-Do, or
  # Time Zone definition object.
  #
  # ### Parsing
  #
  # parser = RecurranceRule.parser
  # recur = parser.parse("FREQ=WEEKLY;UNTIL=19971007T000000Z;WKST=SU;BYDAY=TU,TH")
  # recur.frequency   #=> Weekly
  # recur.end_time    #=> 1997-10-07 00:00:00.0 UTC
  # recur.week_start  #=> Time::DayOfWeek::Sunday
  # recur.by_day      #=> [Time::DayOfWeek::Tuesday, Time::DayOfWeek::Thursday]
  class RecurranceRuleParser < ValueParser(RecurranceRule)
    def parse(string : String, params = {} of String => String) : T
      hash = {} of String => Array(String)
      pairs = string.split(';')
      pairs.each do  |pair|
        name, value = pair.split('=').map(&.downcase)
        hash[name] = value.split(',')
      end

      frequency = RecurranceRule::Freq.from_string(hash["freq"].first)
      interval = hash["interval"]? ? hash["interval"].first.to_i : 1

      if hash["until"]?
        until_string = hash["until"].first.upcase
        end_time = DateTimeParser.parser.parse(until_string)
        RecurranceRule.new(frequency, end_time: end_time, interval: interval)
      elsif hash["count"]?
        count = hash["count"].first.to_i
        RecurranceRule.new(frequency, count: count, interval: interval)
      else
        RecurranceRule.new(frequency, interval: interval)
      end
    end
  end
end
