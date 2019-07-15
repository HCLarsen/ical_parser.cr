require "./../property_parsers/*"

module IcalParser
  class Event
    PROPERTIES = {
      "uid"             => String,
      "dtstamp"         => Time,
      "created"         => Time?,
      "last_mod"        => Time?,
      "dtstart"         => Time,
      "dtend"           => Time?,
      "duration"        => Time::Span?,
      "summary"         => String?,
      "classification"  => String?,
      "categories"      => Array(String),
      "resources"       => Array(String),
      "contacts"        => Array(String),
      "related_to"      => Array(String),
      "request_status"  => Array(String),
      "transp"          => String?,
      "description"     => String?,
      "status"          => String?,
      "comments"        => String?,
      "location"        => String?,
      "priority"        => Int32?,
      "sequence"        => Int32?,
      "organizer"       => CalAddress?,
      "attendees"       => Array(CalAddress),
      "geo"             => Hash(String, Float64)?,
      "recurrence"      => RecurrenceRule?,
      "exdate"          => Array(Time),
      "url"             => URI?
    }

    JSON.mapping(
      uid: {type: String},
      dtstamp: {type: Time, converter: Time::EpochConverter},
      dtstart: {type: Time, converter: Time::EpochConverter},
      dtend: {type: Time?, converter: Time::EpochConverter},
      summary: {type: String?},
      classification: {type: String?, key: "class"},
      categories: {type: Array(String)},
    )

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
    @resources = [] of String
    @contacts = [] of String
    @related_to = [] of String
    @request_status = [] of String
    @attendees = [] of CalAddress
    @exdate = [] of Time
    @rdate = [] of Time | PeriodOfTime
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

    def opaque?
      @transp == "OPAQUE"
    end

    def recurring
      !@recurrence.nil?
    end

    private def later(time : Time, span : (Time::Span | Time::MonthSpan))
      newtime = time + span
      if span.is_a?(Time::Span) && span.days != 0
        if time.zone.dst? && !newtime.zone.dst?
          newtime += Time::Span.new(1, 0, 0)
        elsif !time.zone.dst? && newtime.zone.dst?
          newtime -= Time::Span.new(1, 0, 0)
        end
      end
      newtime
    end

    def_equals @uid, @dtstamp, @dtstart, @dtend, @summary

    private macro verify_vars
      {% for key, value in PROPERTIES %}
        if properties["{{key.id}}"]? && !properties["{{key.id}}"].is_a? {{ value.id }}
          raise "Event Error: {{key.id}} is not a valid type"
        end
      {% end %}
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
