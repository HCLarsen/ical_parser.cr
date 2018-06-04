module IcalParser
  class Event
    getter uid : String
    property dtstamp, dtstart : Time
    property dtend : Time?

    def initialize(@uid : String, @dtstamp : Time, @dtstart : Time)
    end

    def initialize(@uid : String, @dtstamp : Time, @dtstart : Time, dtend : Time)
      check_end_greater_than_start(@dtstart, dtend)
    end

    def initialize(@uid : String, @dtstamp : Time, @dtstart : Time, duration : Time::Span)
      raise "Invalid Event: Duration must be positive" if duration < Time::Span.zero
      @dtend = @dtstart + duration
    end

    def dtstart=(dtstart : Time)
      dtend = @dtend
      if dtend.nil?
        @dtstart = dtstart
      else
        check_end_greater_than_start(dtstart, dtend)
      end
    end

    def dtend=(dtend : Time)
      check_end_greater_than_start(@dtstart, dtend)
    end

    private def check_end_greater_than_start(dtstart : Time, dtend : Time)
      if dtend > dtstart
        @dtstart = dtstart
        @dtend = dtend
      else
        raise "Invalid Event: End time cannot precede start time"
      end
    end
  end
end
