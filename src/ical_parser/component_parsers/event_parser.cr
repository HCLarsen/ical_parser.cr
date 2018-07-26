module IcalParser
  class EventParser
    COMPONENT_PROPERTIES = {
      "uid"             => Property.new(TextParser.parser),
      "dtstamp"         => Property.new(DateTimeParser.parser),
      "dtstart"         => Property.new(DateTimeParser.parser),
      "dtend"           => Property.new(DateTimeParser.parser),
      "duration"        => Property.new(DurationParser.parser),
      "summary"         => Property.new(TextParser.parser),
      "description"     => Property.new(TextParser.parser),
      "classification"  => Property.new(TextParser.parser),
      "categories"      => Property.new(TextParser.parser, single_value: false, only_once: false),
      "transp"          => Property.new(TextParser.parser),
      "status"          => Property.new(TextParser.parser),
      "location"        => Property.new(TextParser.parser),
      "sequence"        => Property.new(IntegerParser.parser),
      "organizer"       => Property.new(CalAddressParser.parser),
      "attendees"       => Property.new(CalAddressParser.parser, only_once: false),
      "geo"             => Property.new(FloatParser.parser, parts: ["lat", "lon"]),
    }

    private def initialize; end

    def self.parser : EventParser
      if @@instance.nil?
        @@instance = new
      else
        @@instance.not_nil!
      end
    end

    def parse(eventc : String)
      all_day = false
      found = Hash(String, PropertyType).new

      lines = content_lines(eventc)

      matches = lines_matches(lines)

      matches.each do |match|
        name = match["name"].downcase
        name = "classification" if name == "class"
        name = "attendees" if name == "attendee"

        if name == "dtstart" && match["params"]?
          params = match["params"].lstrip(';').split((";"))
          all_day = true if params.includes?("VALUE=DATE")
        end

        if COMPONENT_PROPERTIES.keys.includes? name
          property = COMPONENT_PROPERTIES[name]
          value = property.parse(match["value"], match["params"]?)

          unless found[name]?
            found[name] = value
          else
            if property.only_once
              raise "Invalid Event: #{name.upcase} MUST NOT occur more than once"
            else
              found[name] = new_array
            end
          end
        end
      end

      validate(found, all_day)

      event = Event.new(found)
      event.all_day = all_day
      return event
    end

    private def content_lines(component : String)
      lines = component.lines
      lines.shift?
      lines.pop?
      lines
    end

    private def lines_matches(lines : Array(String))
      regex = /(?<name>.*?)(?<params>;.*?)?:(?<value>.*)/

      lines.map do |line|
        if match = line.match(regex)
          match
        else
          raise "Invalid Event: Invalid content line: #{line}"
        end
      end
    end

    private macro new_array
      case value
      {% for type in TYPES %}
      when Array({{type.id}})
        found[name].as Array({{type.id}}) + value
      {% end %}
      else
        raise "Invalid property type"
      end
    end

    private def validate(data, all_day : Bool)
      if data["dtstart"]?
        dtstart = data["dtstart"].as Time
      else
        raise "Invalid Event: DTSTART is REQUIRED"
      end

      if data["dtend"]?
        dtend = data["dtend"].as Time
        if all_day && dtend != dtend.date
          raise "Invalid Event: DTSTART is DATE but DTEND is DATE-TIME"
        end

        if dtend <= dtstart
          raise "Invalid Event: DTEND MUST BE later than DTSTART"
        end

        if data["duration"]?
          raise "Invalid Event: DTEND and DURATION MUST NOT appear in the same event"
        end
      end

      if data["transp"]?
        transp = data["transp"].as String
        if !transp.match(/OPAQUE|TRANSPARENT/)
          raise "Invalid Event: TRANSP must be either OPAQUE or TRANSPARENT"
        end
      end
    end

    def dup
      raise Exception.new("Can't duplicate instance of singleton #{self.class}")
    end
  end
end
