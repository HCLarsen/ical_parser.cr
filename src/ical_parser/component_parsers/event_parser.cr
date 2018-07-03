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
        "uid"             => Property.new(TextParser.parser),
        "dtstamp"         => Property.new(DateTimeParser.parser),
        "dtstart"         => Property.new(DateTimeParser.parser),
        "dtend"           => Property.new(DateTimeParser.parser),
        "summary"         => Property.new(TextParser.parser),
        "classification"  => Property.new(TextParser.parser),
        "categories"      => Property.new(TextParser.parser, Property::Quantity::List),
      }
      found = Hash(String, String | Time | Time::Span | Array(String)).new
      regex = /(?<name>.*?)(?<params>;.*?)?:(?<value>.*)/

      lines = eventc.lines
      lines.each do |line|
        if match = line.match(regex)
          name = match["name"].downcase
          name = "classification" if name == "class"

          if component_properties.keys.includes? name
            property = component_properties[name]

            if property.quantity == Property::Quantity::One
              found[name] = property.parse(match["value"], match["params"]?)
            else
              list = match["value"].split(/(?<!\\),/)
              found[name] = list.map { |e| property.parse(e, match["params"]?).as String }
            end
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
