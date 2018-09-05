module IcalParser
  class EventParser
    LINES_REGEX = /(?<name>.*?)(?<params>;[a-zA-Z\-]*=(?:".*"|[^:;\n]*)+)?:(?<value>.*)/

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
      "resources"       => Property.new(TextParser.parser, single_value: false, only_once: false),
      "contacts"        => Property.new(TextParser.parser, single_value: false, only_once: false),
      "related_to"      => Property.new(TextParser.parser, single_value: false, only_once: false),
      "request_status"  => Property.new(TextParser.parser, only_once: false),
      "transp"          => Property.new(TextParser.parser),
      "status"          => Property.new(TextParser.parser),
      "comments"        => Property.new(TextParser.parser),
      "location"        => Property.new(TextParser.parser),
      "priority"        => Property.new(IntegerParser.parser),
      "sequence"        => Property.new(IntegerParser.parser),
      "organizer"       => Property.new(CalAddressParser.parser),
      "attendees"       => Property.new(CalAddressParser.parser, only_once: false),
      "geo"             => Property.new(FloatParser.parser, parts: ["lat", "lon"]),
      "recurrence"      => Property.new(RecurrenceRuleParser.parser),
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
      property_names = {
        "class"           => "classification",
        "attendee"        => "attendees",
        "comment"         => "comments",
        "contact"         => "contacts",
        "rrule"           => "recurrence",
        "related-to"      => "related_to",
        "request-status"  => "request_status",
      }
      found = Hash(String, PropertyType).new

      lines = content_lines(eventc)

      matches = lines_matches(lines)

      matches.each do |match|
        name = match["name"].downcase
        if property_names.keys.includes?(name)
          name = property_names[name]
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

      validate(found)

      event = Event.new(found)
      event.all_day = validated_all_day?(matches)
      return event
    end

    private def content_lines(component : String)
      lines = component.lines
      lines.shift?
      lines.pop?
      lines
    end

    private def lines_matches(lines : Array(String))
      lines.map do |line|
        if match = line.match(LINES_REGEX)
          match
        else
          raise "Invalid Event: Invalid content line: #{line}"
        end
      end
    end

    private def validated_all_day?(matches : Array(Regex::MatchData)) : Bool
      prop = COMPONENT_PROPERTIES["dtstart"]
      dtstart = matches.select { |e| e["name"].downcase == "dtstart" }.first
      dtend = matches.select { |e| e["name"].downcase == "dtend" }.first?
      duration = matches.select { |e| e["name"].downcase == "duration" }.first?
      start_params = prop.parse_params(dtstart["params"]? || "")
      if dtend
        end_params = prop.parse_params(dtend["params"]? || "")
        if start_params["VALUE"]? != end_params["VALUE"]?
          raise "Invalid Event: DTSTART and DTEND must be the same value type"
        end
      elsif duration
        if start_params["VALUE"]? == "DATE" && duration["value"].match(/[smh]/i)
          raise "Invalid Event: DURATION MUST be day or week duration only"
        end
      end
      start_params["VALUE"]? == "DATE" ? true : false
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

    private def validate(data)
      confirm_mandatory_values_present(data.keys)

      if data["dtend"]?
        dtend = data["dtend"].as Time
        dtstart = data["dtstart"].as Time
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

    private def confirm_mandatory_values_present(found_properties : Array(String))
      mandatory_properties.each do |prop|
        if !found_properties.includes? prop
          raise "Invalid Event: #{prop.upcase} is REQUIRED"
        end
      end
    end

    private def mandatory_properties
      Event::PROPERTIES.select do |k, v|
        !v.nilable? && !v.name.starts_with? "Array"
      end.keys
    end

    def dup
      raise Exception.new("Can't duplicate instance of singleton #{self.class}")
    end
  end
end
