require "./../property_parsers/*"
require "./../property"
require "./../enums"

module IcalParser
  class Event
    PROPERTIES = {
      "uid"             => Property.new("uid"),
      "dtstamp"         => Property.new("dtstamp"),
      "created"         => Property.new("created"),
      "last-modified"   => Property.new("last_modified"),
      "dtstart"         => Property.new("dtstart"),
      "dtend"           => Property.new("dtend"),
      "duration"        => Property.new("duration"),
      "summary"         => Property.new("summary"),
      "description"     => Property.new("description"),
      "class"           => Property.new("classification"),
      "categories"      => Property.new("categories", only_once: false),
      "resources"       => Property.new("resources", only_once: false),
      "contact"         => Property.new("contact", key: "contacts", only_once: false),
      "related-to"      => Property.new("related_to", only_once: false),
      "request-status"  => Property.new("request_status", only_once: false),
      "transp"          => Property.new("transp"),
      "status"          => Property.new("status"),
      "comment"         => Property.new("comment", key: "comments", only_once: false),
      "location"        => Property.new("location"),
      "priority"        => Property.new("priority"),
      "sequence"        => Property.new("sequence"),
      "organizer"       => Property.new("organizer"),
      "attendee"        => Property.new("attendee", key: "attendees", only_once: false),
      "geo"             => Property.new("geo", parts: ["lat", "lon"]),
      "rrule"           => Property.new("rrule"),
      "exdate"          => Property.new("exdate", only_once: false),
      "rdate"           => Property.new("rdate", only_once: false),
      "url"             => Property.new("url"),
    }

    JSON.mapping(
      uid: {type: String},
      dtstamp: {type: Time, converter: Time::ISO8601Converter},
      created: {type: Time?, converter: Time::ISO8601Converter},
      last_modified: {type: Time?, converter: Time::ISO8601Converter},
      dtstart: {type: Time, converter: Time::ISO8601Converter},
      dtend: {type: Time?, converter: Time::ISO8601Converter},
      duration: {type: Duration?},
      summary: {type: String?},
      classification: {type: String?},
      categories: {type: Array(String)?, getter: false},
      resources: {type: Array(String)?, getter: false},
      contacts: {type: Array(String)?, getter: false},
      related_to: {type: Array(String)?, getter: false},
      request_status: {type: Array(String)?, getter: false},
      transp: {type: String?, getter: false},
      description: {type: String?},
      status: {type: String?},
      comments: {type: String?},
      location: {type: String?},
      priority: {type: Int32?},
      sequence: {type: Int32?},
      organizer: {type: CalAddress?},
      attendees: {type: Array(CalAddress)?, getter: false},
      geo: {type: Hash(String, Float64)?},
      rrule: {type: RecurrenceRule?},
      exdate: {type: Array(Time)?, getter: false, converter: JSON::ArrayConverter(Time::ISO8601Converter)},
      url: {type: URI?, converter: URI::URIConverter},
      all_day: {type: Bool?, key: "all-day", getter: false}
    )

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
