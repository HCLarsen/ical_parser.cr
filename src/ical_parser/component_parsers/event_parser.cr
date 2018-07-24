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
        "categories"      => Property.new(TextParser.parser, single_value: false, only_once: false),
        "transp"          => Property.new(TextParser.parser),
        "status"          => Property.new(TextParser.parser),
        "location"        => Property.new(TextParser.parser),
        "sequence"        => Property.new(IntegerParser.parser),
        "organizer"       => Property.new(CalAddressParser.parser),
        "attendees"       => Property.new(CalAddressParser.parser, only_once: false),
        "geo"             => Property.new(FloatParser.parser, parts: ["lat", "lon"]),
      }
      all_day = false
      found = Hash(String, PropertyType).new
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
            value = property.parse(match["value"], match["params"]?)

            unless found[name]?
              found[name] = value
            else
              if property.only_once && property.single_value
              elsif !property.only_once
                case value
                when Array(CalAddress)
                  found[name] = found[name].as Array(CalAddress) + value
                when Array(String)
                  found[name] = found[name].as Array(String) + value
                end
              else
              end
            end
          end
        else
          raise "Invalid Event: No value on line #{line}"
        end
      end

      validate(found, all_day)

      event = Event.new(found)
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
        dtstart = data["dtstart"].as Time
      else
        raise "Invalid Event: DTSTART is REQUIRED"
      end

      if data["dtend"]?
        dtend = data["dtend"].as Time
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
        transp = data["transp"].as String
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
