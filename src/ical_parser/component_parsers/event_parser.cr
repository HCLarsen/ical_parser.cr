module IcalParser
  class EventParser
    private def initialize; end

    def self.parser : EventParser
      if @@instance.nil?
        @@instance = new
      else
        @@instance.not_nil!
      end
    end

    def parse(eventc : String)
      component_properties = {
        "uid" => TextParser,
        "dtstamp" => DateTimeParser,
        "dtstart" => DateTimeParser,
        "dtend" => DateTimeParser,
        "summary" => TextParser,
        "class" => TextParser,
        "categories" => TextParser
      }
      found = Hash(String, String | Time | Time::Span).new
      regex = /(?<name>.*?)(?<params>;.*?)?:(?<value>.*)/

      lines = eventc.lines
      lines.each do |line|
        if match = line.match(regex)
          name = match["name"].downcase
          if component_properties.keys.includes? name
            parser = component_properties[name].parser

            name = "classification" if name == "class"
            
            found[name] = parser.parse(match["value"])
          end
        else
          raise "No match made for invalid line #{line}"
        end
      end

      event = Event.new(found)
    end

    def dup
      raise Exception.new("Can't duplicate instance of singleton #{self.class}")
    end
  end
end
