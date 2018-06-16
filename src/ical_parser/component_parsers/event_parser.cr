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
        "UID" => TextParser,
        "DTSTAMP" => DateTimeParser,
        "DTSTART" => DateTimeParser,
        "DTEND" => DateTimeParser,
        "SUMMARY" => TextParser,
        "CLASS" => TextParser,
        "CATEGORIES" => TextParser
      }
      found = Hash(String, String | Time).new
      regex = /(?<name>.*?)(?<params>;.*?)?:(?<value>.*)/

      lines = eventc.lines
      lines.each do |line|
        if match = line.match(regex)
          name = match["name"]
          if component_properties.keys.includes? name
            parser = component_properties[name].parser
            #puts "#{match["name"]}:#{parser.class}:#{parser.parse(match["value"])}"
            found[name] = parser.parse(match["value"])
          end
        else
          raise "No match made for invalid line #{line}"
        end
      end

      uid = found["UID"].as(String)
      dtstamp = found["DTSTAMP"].as(Time)
      dtstart = found["DTSTART"].as(Time)
      dtend = found["DTEND"].as(Time)

      event = Event.new(uid, dtstamp, dtstart, dtend)
    end

    def dup
      raise Exception.new("Can't duplicate instance of singleton #{self.class}")
    end
  end
end
