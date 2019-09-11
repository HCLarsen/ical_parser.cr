require "./../property_parsers/*"
require "./../property"
require "./../enums"

module IcalParser
  CLASSES = {
    "BOOLEAN"     => Bool,
    "CAL-ADDRESS" => CalAddress,
    "DATE"        => Time,
    "DATE-TIME"   => Time,
    "DURATION"    => Duration,
    "FLOAT"       => Float64,
    "INTEGER"     => Int32,
    "PERIOD"      => PeriodOfTime,
    "RECUR"       => RecurrenceRule,
    "TEXT"        => String,
    "TIME"        => Time,
    "URI"         => URI,
  }

  class Event
    macro mapping
      JSON.mapping(
        {% for key, value in PROPERTIES %}
          {% _property = COMPONENT_PROPERTIES[value[:name]] %}
          {% _class = CLASSES[_property[:types][0]] %}
          {% value[:type] = _class %}
          {% value[:key] = value[:key] || value[:name] %}
          {% value[:nilable] = !value[:required] %}
          {% value[:converter] = _property[:converter] %}
          {% if value[:only_once] == false || _property[:list] == true %}
            {{value[:key].id}}: { type: Array({{_class.id}}){{ (value[:required] ? "" : "?").id }}, converter: {{value[:converter]}} },
          {% elsif _property[:parts] %}
            {{value[:key].id}}: { type: Hash(String, {{_class.id}}){{ (value[:required] ? "" : "?").id }} , converter: {{value[:converter]}} },
          {% else %}
            {{value[:key].id}}: {{value.id}},
          {% end %}
        {% end %}
        all_day: {type: Bool?, key: "all-day", getter: false}
      )
    end

    PROPERTIES = {
      "uid"             => { name: "uid", required: true },
      "dtstamp"         => { name: "dtstamp", required: true },
      "created"         => { name: "created" },
      "last-modified"   => { name: "last_modified" },
      "dtstart"         => { name: "dtstart", required: true },
      "dtend"           => { name: "dtend" },
      "duration"        => { name: "duration" },
      "summary"         => { name: "summary" },
      "description"     => { name: "description" },
      "class"           => { name: "classification" },
      "categories"      => { name: "categories", only_once: false },
      "resources"       => { name: "resources", only_once: false },
      "contact"         => { name: "contact", key: "contacts", only_once: false },
      "related-to"      => { name: "related_to", only_once: false },
      "request-status"  => { name: "request_status", only_once: false },
      "transp"          => { name: "transp" },
      "status"          => { name: "status" },
      "comment"         => { name: "comment", key: "comments", only_once: false },
      "location"        => { name: "location" },
      "priority"        => { name: "priority" },
      "sequence"        => { name: "sequence" },
      "organizer"       => { name: "organizer" },
      "attendee"        => { name: "attendee", key: "attendees", only_once: false },
      "geo"             => { name: "geo" },
      "rrule"           => { name: "rrule" },
      "exdate"          => { name: "exdate", only_once: false },
      "url"             => { name: "url" },
    }

    mapping

    getter? all_day
    getter attendees, type: Array(CalAddress), value: [] of CalAddress
    getter categories, contacts, resources, related_to, request_status, type: Array(String), value: [] of String
    getter exdate, type: Array(Time), value: [] of Time
    getter rdate, type: Array(Time | PeriodOfTime), value: [] of Time | PeriodOfTime
    getter transp, type: String, value: "OPAQUE"
    getter classification, type: String, value: "PUBLIC"

    def_equals @uid, @dtstamp, @dtstart, @dtend, @summary

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

    def duration : Duration
      if dtend = @dtend
        Duration.between(@dtstart, dtend)
      else
        Duration.new
      end
    end

    def duration=(duration : Duration)
      if duration >= Duration.new
        @duration = duration
      else
        raise "Error: Duration value must be greater than zero"
      end
    end

    def opaque?
      @transp != "TRANSPARENT"
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

    private def check_end_greater_than_start(dtstart : Time, dtend : Time)
      if dtend > dtstart
        @dtstart = dtstart
        @dtend = dtend
      else
        raise "Invalid Event: End time cannot precede start time"
      end
    end

    def initialize(pull : JSON::PullParser)
      previous_def
      duration = @duration
      unless duration.nil?
        @dtend = @dtstart.shift(days: duration.days, hours: duration.hours, minutes: duration.minutes, seconds: duration.seconds)
      end
    end
  end
end
