require "./../property_parsers/*"

module IcalParser
  class Event
    JSON.mapping(
      uid: {type: String},
      dtstamp: {type: Time, converter: Time::ISO8601Converter},
      created: {type: Time?, converter: Time::ISO8601Converter},
      last_mod: {type: Time?, key: "last-mod", converter: Time::ISO8601Converter},
      dtstart: {type: Time, converter: Time::ISO8601Converter},
      dtend: {type: Time?, converter: Time::ISO8601Converter},
      duration: {type: Duration?},
      summary: {type: String?},
      classification: {type: String?},
      categories: {type: Array(String)?},
      resources: {type: Array(String)?},
      contacts: {type: Array(String)?},
      related_to: {type: Array(String)?, key: "related-to"},
      request_status: {type: Array(String)?, key: "request-status"},
      transp: {type: String?},
      description: {type: String?},
      status: {type: String?},
      comments: {type: String?},
      location: {type: String?},
      priority: {type: Int32?},
      sequence: {type: Int32?},
      organizer: {type: CalAddress?},
      attendees: {type: Array(CalAddress)?},
      geo: {type: Hash(String, Float64)?},
      recurrence: {type: RecurrenceRule?},
      exdate: {type: Array(Time)?, converter: JSON::ArrayConverter(Time::ISO8601Converter)},
      url: {type: URI?, converter: URI::URIConverter},
      all_day: {type: Bool?, key: "all-day"}
    )

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

    # def duration : Time::Span
    #   if dtend = @dtend
    #     dtend - @dtstart
    #   else
    #     Time::Span.zero
    #   end
    # end
    #
    # def duration=(duration : Time::Span)
    #   if duration > Time::Span.zero
    #     @dtend = @dtstart + duration
    #   else
    #     raise "Error: Duration value must be greater than zero"
    #   end
    # end
    #
    def all_day?
      @all_day
    end

    def all_day=(value : Bool)
      @all_day = value
    end

    def categories
      @categories || [] of String
    end

    def attendees
      @attendees || [] of CalAddress
    end

    def contacts
      @contacts || [] of String
    end

    def resources
      @resources || [] of String
    end

    def related_to
      @related_to || [] of String
    end

    def request_status
      @request_status || [] of String
    end

    def exdate
      @exdate || [] of Time
    end

    def rdate
      @rdate || [] of Time | PeriodOfTime
    end


    def transp
      @transp || "OPAQUE"
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

    def_equals @uid, @dtstamp, @dtstart, @dtend, @summary

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
