require "json"

module IcalParser
  class Duration
    JSON.mapping(
      weeks: { type: Int32?, getter: false, default: nil },
      days: { type: Int32?, getter: false, default: nil },
      hours: { type: Int32?, getter: false, default: nil },
      minutes: { type: Int32?, getter: false, default: nil },
      seconds: { type: Int32?, getter: false, default: nil },
    )

    def initialize(@weeks : Int32)
    end

    def initialize(*, days = nil, hours = nil, minutes = nil, seconds = nil)
      @days = days if days != 0
      @hours = hours if hours != 0
      @minutes = minutes if minutes != 0
      @seconds = seconds if seconds != 0
    end

    def initialize(pull : JSON::PullParser)
      previous_def
      if (@days || @hours || @minutes || @seconds) && @weeks
        raise "Error: Week durations cannot be combined with other duration units"
      end
    end

    def self.between(first : Time, second : Time) : Duration
      days = second.day - first.day
      hours = second.hour - first.hour
      minutes = second.minute - first.minute
      seconds = second.second - first.second
      if days >= 0
        if seconds < 0
          minutes -= 1
          seconds += 60
        end
        if minutes < 0
          hours -= 1
          minutes += 60
        end
      end
      Duration.new(days: days, hours: hours, minutes: minutes, seconds: seconds)
    end

    def_equals @weeks, @days, @hours, @minutes, @seconds

    def weeks
      @weeks || 0
    end

    def days
      @days || 0
    end

    def hours
      @hours || 0
    end

    def minutes
      @minutes || 0
    end

    def seconds
      @seconds || 0
    end
  end
end
