module IcalParser
  class CalendarParser
    private def initialize; end

    def self.parser : CalendarParser
      if @@instance.nil?
        @@instance = new
      else
        @@instance.not_nil!
      end
    end

    def parse(calendar_object : String)
      calendar_properties = {
        "prodid"    => Property.new(TextParser.parser),
        "version"   => Property.new(TextParser.parser),
        "calscale"  => Property.new(TextParser.parser),
        "method"    => Property.new(TextParser.parser),
      }

      line_regex = /(?<name>.*?)(?<params>;.*?)?:(?<value>.*)/
      component_regex = /^BEGIN:(?<type>.*?)$.*?^END:.*?$/m

      found = {} of String => String
      events = [] of Event

      calendar_object = remove_first_and_last_lines(calendar_object)

      components = calendar_object.scan(component_regex)
      components.each do |component|
        if component["type"].strip == "VEVENT"
          events << EventParser.parser.parse(component[0])
        end
      end

      lines = calendar_object.lines
      lines.each do |line|
        if match = line.match(line_regex)
          name = match["name"].downcase
          if calendar_properties.keys.includes? name
            property = calendar_properties[name]
            found[name] = property.parse(match["value"], match["params"]?)
          end
        end
      end

      Calendar.new(found, events)
    end

    def dup
      raise Exception.new("Can't duplicate instance of singleton #{self.class}")
    end

    private def remove_first_and_last_lines(string : String)
      lines = string.lines
      lines.shift?
      lines.pop?
      lines.join("\r\n")
    end
  end
end
