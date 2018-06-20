module IcalParser
  class PeriodOfTime
    property start_time : Time
    getter end_time : Time

    def initialize(@start_time : Time, @end_time : Time)
      raise "Invalid PeriodOfTime: end_time must be later than start time" if @end_time <= @start_time
    end

    def initialize(@start_time : Time, duration : Time::Span)
      raise "Invalid PeriodOfTime: duration must be positive" if duration <= Time::Span.zero
      @end_time = @start_time + duration
    end

    def duration
      @end_time - @start_time
    end

    def start_time=(start_time : Time)
      raise "Invalid start_time: must be earlier than end time" if start_time > @end_time
      @start_time = start_time
    end

    def end_time=(end_time : Time)
      raise "Invalid end_time: must be later than start time" if end_time <= @start_time
      @end_time = end_time
    end

    def duration=(duration : Time::Span)
      raise "Invalid duration: must be positive" if duration <= Time::Span.zero
      @end_time = @start_time + duration
    end
  end
end
