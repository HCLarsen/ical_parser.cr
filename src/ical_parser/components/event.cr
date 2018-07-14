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
      "transp"          => String?,
      "description"     => String?,
      "status"          => String?,
      "location"        => String?,
      "sequence"        => Int32?,
      "organizer"       => CalAddress?,
      "attendees"       => Array(CalAddress),
    }

    @all_day = false
    {% for key, value in PROPERTIES %}
      {% if key.id == "uid" %}
        getter {{key.id}} : {{value.id}}
      {% elsif key.id != "duration" %}
        property {{key.id}} : {{value.id}}
      {% end %}
    {% end %}
    {% debug %}

    @categories = [] of String
    @attendees = [] of CalAddress
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

    def initialize(properties : Hash(String, ICalValue))
      @uid = properties["uid"].as String
      @dtstamp = properties["dtstamp"].as Time
      @dtstart = properties["dtstart"].as Time

      if duration = properties["duration"]?
        @dtend = @dtstart + duration.as Time::Span
      end

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

    def duration : Time::Span
      if dtend = @dtend
        dtend - @dtstart
      else
        Time::Span.zero
      end
    end

    def duration=(duration : Time::Span)
      if duration > Time::Span.zero
        @dtend = @dtstart + duration
      else
        raise "Error: Duration value must be greater than zero"
      end
    end

    def all_day?
      @all_day
    end

    def all_day=(value : Bool)
      @all_day = value
    end

    private macro assign_vars
      {% for key, value in PROPERTIES %}
        {% if key.id != "duration" %}
          @{{key.id}} = properties[{{key}}].as {{value.id}} if properties[{{key}}]?
        {% end %}
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
