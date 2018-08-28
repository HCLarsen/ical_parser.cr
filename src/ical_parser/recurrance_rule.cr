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

      def self.from_string(string : String)
        case string
        when "secondly"
          Secondly
        when "minutely"
          Minutely
        when "hourly"
          Hourly
        when "daily"
          Daily
        when "weekly"
          Weekly
        when "monthly"
          Monthly
        when "yearly"
          Yearly
        else
          raise "Invalid Recurrance Rule FREQ value"
        end
      end
    end

    alias ByRuleType = Array({Int32, Time::DayOfWeek}) | Array(Int32)

    property frequency : Freq
    getter count : Int32?
    getter end_time : Time?
    property interval = 1
    property week_start = Time::DayOfWeek::Monday
    property by_month = [] of Int32
    property by_week = [] of Int32
    property by_year_day = [] of Int32
    property by_month_day = [] of Int32
    property by_day = [] of {Int32, Time::DayOfWeek}
    property by_hour = [] of Int32
    property by_minute = [] of Int32
    property by_second = [] of Int32
    property by_set_pos = [] of Int32

    def initialize(@frequency : Freq, @count = nil, @interval = 1)
    end

    def initialize(@frequency : Freq, @end_time : Time, @interval = 1)
    end

    def initialize(@frequency : Freq, *, by_rules : Hash(String, ByRuleType), @end_time : Time,  @interval = 1, week_start : Time::DayOfWeek? = nil)
      assign_rules(by_rules)
      @week_start = week_start if week_start
    end

    def initialize(@frequency : Freq, *, by_rules : Hash(String, ByRuleType), @count = nil, @interval = 1, week_start : Time::DayOfWeek? = nil)
      assign_rules(by_rules)
      @week_start = week_start if week_start
    end

    def assign_rules(rules : Hash(String, ByRuleType))
      @by_month = rules["by_month"].as? Array(Int32) if rules["by_month"]?
      @by_week = rules["by_week"].as? Array(Int32) if rules["by_week"]?
      @by_year_day = rules["by_year_day"].as? Array(Int32) if rules["by_year_day"]?
      @by_month_day = rules["by_month_day"].as? Array(Int32) if rules["by_month_day"]?
      @by_day = rules["by_day"].as? Array({Int32, Time::DayOfWeek}) if rules["by_day"]?
      @by_hour = rules["by_hour"].as? Array(Int32) if rules["by_hour"]?
      @by_minute = rules["by_minute"].as? Array(Int32) if rules["by_minute"]?
      @by_second = rules["by_second"].as? Array(Int32) if rules["by_second"]?
      @by_set_pos = rules["by_set_pos"].as? Array(Int32) if rules["by_set_pos"]?
    end

    def count=(count : Int32)
      unless @end_time
        @count = count
      else
        raise "Invalid Assignment: Recurrance Rule cannot have both a count and an end time"
      end
    end

    def end_time=(end_time : Time)
      unless @count
        @end_time = end_time
      else
        raise "Invalid Assignment: Recurrance Rule cannot have both a count and an end time"
      end
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
