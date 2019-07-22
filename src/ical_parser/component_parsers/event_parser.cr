module IcalParser
  class EventParser
    LINES_REGEX = /(?<name>.*?)(?<params>;[a-zA-Z\-]*=(?:".*"|[^:;\n]*)+)?:(?<value>.*)/

    COMPONENT_PROPERTIES = {
      "uid"             => Property.new(PARSERS["TEXT"]),
      "dtstamp"         => Property.new(PARSERS["DATE-TIME"]),
      "created"         => Property.new(PARSERS["DATE-TIME"]),
      "last-mod"        => Property.new(PARSERS["DATE-TIME"]),
      "dtstart"         => Property.new(PARSERS["DATE-TIME"], alt_values: ["DATE"]),
      "dtend"           => Property.new(PARSERS["DATE-TIME"], alt_values: ["DATE"]),
      "duration"        => Property.new(PARSERS["DURATION"]),
      "summary"         => Property.new(PARSERS["TEXT"]),
      "description"     => Property.new(PARSERS["TEXT"]),
      "classification"  => Property.new(PARSERS["TEXT"]),
      "categories"      => Property.new(PARSERS["TEXT"], single_value: false, only_once: false),
      "resources"       => Property.new(PARSERS["TEXT"], single_value: false, only_once: false),
      "contacts"        => Property.new(PARSERS["TEXT"], single_value: false, only_once: false),
      "related_to"      => Property.new(PARSERS["TEXT"], single_value: false, only_once: false),
      "request-status"  => Property.new(PARSERS["TEXT"], only_once: false),
      "transp"          => Property.new(PARSERS["TEXT"]),
      "status"          => Property.new(PARSERS["TEXT"]),
      "comments"        => Property.new(PARSERS["TEXT"]),
      "location"        => Property.new(PARSERS["TEXT"]),
      "priority"        => Property.new(PARSERS["INTEGER"]),
      "sequence"        => Property.new(PARSERS["INTEGER"]),
      "organizer"       => Property.new(PARSERS["CAL-ADDRESS"]),
      "attendees"       => Property.new(PARSERS["CAL-ADDRESS"], only_once: false),
      "geo"             => Property.new(PARSERS["FLOAT"], parts: ["lat", "lon"]),
      "recurrence"      => Property.new(PARSERS["RECUR"]),
      "exdate"          => Property.new(PARSERS["DATE-TIME"], single_value: false, only_once: false),
      "url"             => Property.new(PARSERS["URI"]),
    }

    private def initialize; end

    def self.parser : EventParser
      if @@instance.nil?
        @@instance = new
      else
        @@instance.not_nil!
      end
    end

    def parse(eventc : String) : Event
      found = parse_to_json(eventc)
      Event.from_json(found)
    end

    def parse_to_json(eventc : String) : String
      property_names = {
        "last-modified"   => "last-mod",
        "class"           => "classification",
        "attendee"        => "attendees",
        "comment"         => "comments",
        "contact"         => "contacts",
        "rrule"           => "recurrence",
      }
      found = Hash(String, String).new

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
              value = value.strip("[]")
              found[name] = found[name].insert(-2, ",#{value}")
            end
          end
        end
      end

      props = Array(String).new
      found.map do |k, v|
        props << %("#{k}":#{v})
      end

      if found["dtstart"].match(/^"\d{4}-\d{2}-\d{2}"$/)
        props << %("all-day":true)
      end

      %({#{props.join(",")}})
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
