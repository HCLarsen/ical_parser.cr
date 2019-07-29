module IcalParser
  class CalendarParser
    LINES_REGEX = /(?<name>.*?)(?<params>;[a-zA-Z\-]*=(?:".*"|[^:;\n]*)+)?:(?<value>.*)/
    COMPONENT_REGEX = /^BEGIN:(?<type>.*?)$.*?^END:.*?$/m

    COMPONENT_PROPERTIES = {
      "prodid"    => Property.new(PARSERS["TEXT"]),
      "version"   => Property.new(PARSERS["TEXT"]),
      "calscale"  => Property.new(PARSERS["TEXT"]),
      "method"    => Property.new(PARSERS["TEXT"]),
    }

    private def initialize; end

    def self.parser : CalendarParser
      if @@instance.nil?
        @@instance = new
      else
        @@instance.not_nil!
      end
    end

    def parse(calendar_object : String)
      found = parse_to_json(calendar_object)
      Calendar.from_json(found)
    end

    def parse_to_json(calendar_object : String) : String
      calendar_object = calendar_object.lchop("BEGIN:VCALENDAR\r\n").rchop("END:VCALENDAR")
      calendar_object = unfold(calendar_object)

      props = parse_properties(calendar_object)
      events = parse_components(calendar_object)

      props.concat(events)

      %({#{props.join(",")}})
    end

    private def parse_properties(calendar_object : String) : Array(String)
      found = Hash(String, String).new

      lines = content_lines(calendar_object)
      matches = lines_matches(lines)

      matches.each do |match|
        name = match["name"].downcase

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

      found.map do |k, v|
        %("#{k}":#{v})
      end
    end

    private def parse_components(calendar_object) : Array(String)
      found = Hash(String, Array(String)).new

      events = [] of String
      components = calendar_object.scan(COMPONENT_REGEX)
      components.each do |component|
        if component["type"].strip == "VEVENT"
          if found["events"]?
            found["events"] << EventParser.parser.parse_to_json(component[0])
          else
            found["events"] = [EventParser.parser.parse_to_json(component[0])]
          end
        end
      end

      found.map do |k, v|
        %("#{k}":[#{v.join(",")}])
      end
    end

    private def content_lines(component : String)
      lines = component.lines
      lines
    end

    private def lines_matches(lines : Array(String))
      lines.map_with_index do |line, index|
        if match = line.match(LINES_REGEX)
          match
        else
          raise "Invalid Event: Invalid content line ##{index}: #{line}"
        end
      end
    end

    private def unfold(string : String)
      string.gsub("\r\n ", "")
    end

    def dup
      raise Exception.new("Can't duplicate instance of singleton #{self.class}")
    end
  end
end
