module IcalParser
  # Representation of the Recurrance Rule.
  #
  # This class defines the repetition pattern of an event, to-do, jounral entry or time zone definition.
  #
  # # Specifies a recurrance rule for an event that will repeat every 2 days, up to 10 times.
  # recur = RecurranceRule.new(RecurranceRule::Freq::Daily, 10, 2)
  # recur.frequency #=> Daily
  # recur.count     #=> 10
  # recur.interval  #=> 2
  #
  # # Defines an Event that will repeat every year, indefinitely.
  # recur = RecurranceRule.new(RecurranceRule::Freq::Yearly)
  # props = {
  #   "uid"         => "canada-day@example.com",
  #   "dtstamp"     => Time.utc(1867, 3, 29, 13, 0, 0),
  #   "dtstart"     => Time.utc(1867, 7, 1),
  #   "recurrance"  => recur
  # } of String => PropertyType
  # event = IcalParser::Event.new(props)
  # event.recurring             #=> true
  # event.recurrance.frequency  #=> Yearly
  struct RecurranceRule
    enum Freq
      Secondly
      Minutely
      Hourly
      Daily
      Weekly
      Monthly
      Yearly
    end

    property frequency : Freq
    property count : Int32?
    property interval = 1
    property end_time : Time?
    property week_start = Time::DayOfWeek::Monday
    property by_day = [] of {Int32, Time::DayOfWeek}

    def initialize(@frequency : Freq, @count = nil, @interval = 1)
    end

    def initialize(@frequency : Freq, @end_time : Time, @interval = 1)
    end

    def initialize(@frequency : Freq, @count : Int32, @interval = 1, @by_day = [] of {Int32, Time::DayOfWeek}, week_start : Time::DayOfWeek? = nil)
      @week_start = week_start if week_start != nil
    end

    def total_frequency : Time::Span | Time::MonthSpan
      case @frequency
      when Freq::Yearly
        @interval.years
      when Freq::Monthly
        @interval.months
      when Freq::Weekly
        @interval.weeks
      when Freq::Daily
        @interval.days
      when Freq::Hourly
        @interval.hours
      when Freq::Minutely
        @interval.minutes
      when Freq::Secondly
        @interval.seconds
      else
        raise "Invalid Frequency value"
      end
    end
  end
end
