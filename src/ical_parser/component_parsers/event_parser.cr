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
        "duration"        => Property.new(DurationParser.parser),
        "summary"         => Property.new(TextParser.parser),
        "description"     => Property.new(TextParser.parser),
        "classification"  => Property.new(TextParser.parser),
        "categories"      => Property.new(TextParser.parser, Property::Quantity::List),
        "transp"          => Property.new(TextParser.parser),
        "status"          => Property.new(TextParser.parser),
        "location"        => Property.new(TextParser.parser),
        "sequence"        => Property.new(IntegerParser.parser),
        "organizer"       => Property.new(CalAddressParser.parser),
        "attendees"        => Property.new(CalAddressParser.parser, more_than_once: true),
      }
      all_day = false
      found = Hash(String, Array(ValueType)).new
      regex = /(?<name>.*?)(?<params>;.*?)?:(?<value>.*)/

      eventc = remove_first_and_last_lines(eventc)

      lines = eventc.lines
      lines.each do |line|
        if match = line.match(regex)
          name = match["name"].downcase
          name = "classification" if name == "class"
          name = "attendees" if name == "attendee"
          all_day = true if name == "dtstart" && match["params"]? && match["params"].match(/VALUE=DATE(?:$|[^-])/)

          if component_properties.keys.includes? name
            property = component_properties[name]

            found[name] = [] of ValueType if !found[name]?

            if property.quantity == Property::Quantity::One
              found[name] << property.parse(match["value"], match["params"]?)
            else
              values = match["value"].split(/(?<!\\),/)
              found[name] = found[name] + values.map { |e| property.parse(e, match["params"]?).as String }
            end
          end
        else
          raise "Invalid Event: No value on line #{line}"
        end
      end

      validate(found, all_day)

      collected = Hash(String, PropertyType).new
      found.each do |name, value|
        if name == "categories"
          collected[name] = value.map { |e| e.as String}
        elsif name == "attendees"
          collected[name] = value.map { |e| e.as CalAddress}
        else
          collected[name] = value.first
        end
      end

      event = Event.new(collected)
      event.all_day = all_day
      return event
    end

    private def remove_first_and_last_lines(string : String)
      lines = string.lines
      lines.shift?
      lines.pop?
      lines.join("\r\n")
    end

    private def validate(data, all_day : Bool)
      if data["dtstart"]?
        dtstart = data["dtstart"].first.as Time
      else
        raise "Invalid Event: DTSTART is REQUIRED"
      end

      if data["dtend"]?
        dtend = data["dtend"].first.as Time
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
        transp = data["transp"].first.as String
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
