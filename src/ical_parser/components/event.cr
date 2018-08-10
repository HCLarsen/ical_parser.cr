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
      "geo"             => Hash(String, Float64)?,
      "recurrance"      => RecurranceRule?
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

    def initialize(properties : Hash(String, PropertyType))
      verify_vars

      @uid = properties["uid"].as String
      @dtstamp = properties["dtstamp"].as Time
      @dtstart = properties["dtstart"].as Time

      if duration = properties["duration"]?
        @dtend = @dtstart + duration.as Time::Span
      end

      assign_vars
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
      puts "Assigning duration"
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
      !@recurrance.nil?
    end

    def occurences
      recurrance
      limit = 10
      array = [self]

      if recurrance = @recurrance
        frequency = recurrance.total_frequency
        start = self.dtstart
        if count = recurrance.count
          (count - 1).times do |num|
            start = later(start, frequency)
            array << Event.new(self.uid, self.dtstamp, start)
          end
        elsif last = recurrance.end_time
          start = later(start, frequency)
          while start <= last
            array << Event.new(self.uid, self.dtstamp, start)
            start = later(start, frequency)
          end
        else
          (limit - 1).times do |num|
            start = later(start, frequency)
            array << Event.new(self.uid, self.dtstamp, start)
          end
        end
      end

      array
    end

    private def later(time : Time, span : (Time::Span | Time::MonthSpan))
      newtime = time + span
      if time.zone.dst? && !newtime.zone.dst?
    	  newtime += Time::Span.new(1, 0, 0)
    	elsif !time.zone.dst? && newtime.zone.dst?
    	  newtime -= Time::Span.new(1, 0, 0)
    	end
    	newtime
    end

    def_equals @uid, @dtstamp, @dtstart, @dtend, @summary

    private macro assign_vars
      {% for key, value in PROPERTIES %}
        {% if key.id != "duration" %}
          @{{key.id}} = properties[{{key}}].as {{value.id}} if properties[{{key}}]?
        {% end %}
      {% end %}
    end

    private macro verify_vars
      {% for key, value in PROPERTIES %}
        if properties["{{key.id}}"]? && !properties["{{key.id}}"].is_a? {{ value.id }}
          raise "Event Error: {{key.id}} is not a valid type"
        end
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
