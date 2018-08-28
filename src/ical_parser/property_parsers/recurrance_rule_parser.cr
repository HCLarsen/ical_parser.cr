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
  end
end
