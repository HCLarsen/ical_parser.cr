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

    def parse_to_json(calendar_object : String)
      found = Hash(String, String).new

      calendar_object = unfold(calendar_object)
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

      props = Array(String).new
      found.map do |k, v|
        props << %("#{k}":#{v})
      end

      events = [] of String
      components = lines.join("\n").scan(COMPONENT_REGEX)
      components.each do |component|
        if component["type"].strip == "VEVENT"
          events << EventParser.parser.parse_to_json(component[0])
        end
      end

      props << %("events":[#{events.join(",")}])

      %({#{props.join(",")}})
    end

    private def parse_components(args_name)
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

    private def remove_first_and_last_lines(string : String)
      lines = string.lines
      lines.shift?
      lines.pop?
      lines.join("\r\n")
    end

    private def unfold(string : String)
      string.gsub("\r\n ", "")
    end

    def dup
      raise Exception.new("Can't duplicate instance of singleton #{self.class}")
    end
  end
end
