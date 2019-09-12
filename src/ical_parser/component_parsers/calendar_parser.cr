require "./../components/calendar"

module IcalParser
  class CalendarParser
    DELIMITER = "VCALENDAR"
    LINES_REGEX = /(?<name>.*?)(?<params>;[a-zA-Z\-]*=(?:".*"|[^:;\n]*)+)?:(?<value>.*)/
    COMPONENT_REGEX = /^BEGIN:(?<type>.*?)$.*?^END:\k<type>$/m

    PROPERTIES = Calendar::PROPERTIES
    PROPERTY_KEYS = Calendar::PROPERTIES.keys

    COMPONENTS = Calendar::COMPONENTS

    private def initialize; end

    def self.parser : CalendarParser
      if @@instance.nil?
        @@instance = new
      else
        @@instance.not_nil!
      end
    end

    def parse(component : String)
      found = parse_to_json(component)
      Calendar.from_json(found)
    end

    def parse_to_json(component : String) : String
      component = remove_delimiters(component)
      component = unfold(component)

      props = parse_properties(component)
      components = parse_components(component)

      props.concat(components)

      %({#{props.join(",")}})
    end

    private def parse_properties(component : String) : Array(String)
      found = Hash(String, String).new

      lines = content_lines(component)
      matches = lines_matches(lines)

      matches.each do |match|
        name = match["name"].downcase

        if PROPERTY_KEYS.includes? name
          property = Property.new(Calendar::PROPERTIES[name])

          key = property.key
          value = property.parse(match["value"], match["params"]?)

          unless found[key]?
            found[key] = value
          else
            if property.only_once
              raise "Invalid Event: #{name.upcase} MUST NOT occur more than once"
            else
              value = value.strip("[]")
              found[key] = found[key].insert(-2, ",#{value}")
            end
          end
        end
      end

      if found["dtstart"]? && found["dtstart"].match(/^"\d{4}-\d{2}-\d{2}"$/)
        found["all-day"] = "true"
      end

      found.map do |k, v|
        %("#{k}":#{v})
      end
    end

    private def parse_components(component : String) : Array(String)
      found = Hash(String, Array(String)).new

      events = [] of String
      components = component.scan(COMPONENT_REGEX)
      components.each do |component|
        name = component["type"].strip
        if COMPONENTS.keys.includes? name
          key = COMPONENTS[name]["key"]
          parser = COMPONENTS[name]["parser"].parser
          if found[key]?
            found[key] << parser.parse_to_json(component[0])
          else
            found[key] = [parser.parse_to_json(component[0])]
          end
        end
      end

      found.map do |k, v|
        %("#{k}":[#{v.join(",")}])
      end
    end

    private def remove_delimiters(component : String) : String
      component.lchop("BEGIN:#{DELIMITER}\r\n").rchop("END:#{DELIMITER}")
    end

    private def content_lines(component : String) : Array(String)
      component = component.gsub(/#{COMPONENT_REGEX}\n/, nil)
      lines = component.lines
      lines
    end

    private def lines_matches(lines : Array(String)) : Array(Regex::MatchData)
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
