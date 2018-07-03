require "./../property_parsers/*"

module IcalParser
  class Event
    PROPERTIES = {
      "uid"             => String,
      "dtstamp"         => Time,
      "dtstart"         => Time,
      "dtend"           => Time?,
      "duration"        => Time::Span?,
      "summary"         => String?,
      "classification"  => String?,
      "categories"      => Array(String),
      "transp"           => String
    }

    @all_day = false

    getter uid : String
    property dtstamp, dtstart : Time
    property dtend : Time?
    @duration : Time::Span?
    property summary : String?
    property classification : String?
    property categories = [] of String
    @transp = "OPAQUE"

    def initialize(@uid : String, @dtstamp : Time, @dtstart : Time)
    end

    def initialize(@uid : String, @dtstamp : Time, @dtstart : Time, dtend : Time)
      check_end_greater_than_start(@dtstart, dtend)
    end

    def initialize(@uid : String, @dtstamp : Time, @dtstart : Time, duration : Time::Span)
      raise "Invalid Event: Duration must be positive" if duration < Time::Span.zero
      @dtend = @dtstart + duration
    end

    def initialize(properties : Hash(String, String | Time | Time::Span | Array(String)))
      @uid = properties["uid"].as String
      @dtstamp = properties["dtstamp"].as Time
      @dtstart = properties["dtstart"].as Time

      assign_vars
    end

    def opaque?
      @transp == "OPAQUE"
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

    def all_day?
      @all_day
    end

    def all_day=(value : Bool)
      @all_day = value
    end

    private macro assign_vars
      {% for key, value in PROPERTIES %}
        @{{key.id}} = properties[{{key}}].as {{value.id}} if properties[{{key}}]?
      {% end %}
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
