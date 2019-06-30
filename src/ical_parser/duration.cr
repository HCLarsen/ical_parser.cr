module IcalParser
  class Duration
    JSON.mapping(
      weeks: { type: Int32?, getter: false },
      days: { type: Int32?, getter: false },
      hours: { type: Int32?, getter: false },
      minutes: { type: Int32?, getter: false },
      seconds: { type: Int32?, getter: false },
    )

    getter(weeks) { 0 }
    getter(days) { 0 }
    getter(hours) { 0 }
    getter(minutes) { 0 }
    getter(seconds) { 0 }

    def initialize(@weeks : Int32)
    end

    def initialize(@days : Int32, @hours : Int32, @minutes : Int32, @seconds : Int32)
    end

    def initialize(pull : JSON::PullParser)
      previous_def
      if (@days || @hours || @minutes || @seconds) && @weeks
        raise "Error: Week durations cannot be combined with other duration units"
      end
    end
  end
end
