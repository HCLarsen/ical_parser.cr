require "./../components/event"

module IcalParser
  class EventParser
    DELIMITER = "VEVENT"
    LINES_REGEX = /(?<name>.*?)(?<params>;[a-zA-Z\-]*=(?:".*"|[^:;\n]*)+)?:(?<value>.*)/
    COMPONENT_REGEX = /^BEGIN:(?<type>.*?)$.*?^END:.*?$/m

    PROPERTY_KEYS = ["uid", "dtstamp", "created", "last-mod", "dtstart", "dtend", "duration", "summary", "description", "classification", "categories", "resources", "contacts", "related_to", "request-status", "transp", "status", "comments", "location", "priority", "sequence", "organizer", "attendees", "geo", "recurrence", "exdate", "rdate", "url"]

    PROPERTIES = Event::PROPERTIES

    private def initialize; end

    def self.parser : EventParser
      if @@instance.nil?
        @@instance = new
      else
        @@instance.not_nil!
      end
    end

    def parse(component : String) : Event
      found = parse_to_json(component)
      Event.from_json(found)
    end

    def parse_to_json(component : String) : String
      component = remove_delimiters(component)
      props = parse_properties(component)

      %({#{props.join(",")}})
    end

    private def parse_properties(component : String) : Array(String)
      property_names = {
        "attendee"        => "attendees",
        "comment"         => "comments",
        "contact"         => "contacts",
      }
      found = Hash(String, String).new

      lines = content_lines(component)
      matches = lines_matches(lines)

      matches.each do |match|
        name = match["name"].downcase
        if property_names[name]?
          name = property_names[name]
        end

        if PROPERTIES.keys.includes? name
          property = PROPERTIES[name]
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

      if found["dtstart"]? && found["dtstart"].match(/^"\d{4}-\d{2}-\d{2}"$/)
        found["all-day"] = "true"
      end

      found.map do |k, v|
        %("#{k}":#{v})
      end
    end

    private def remove_delimiters(component : String) : String
      component.lchop("BEGIN:#{DELIMITER}\r\n").rchop("END:#{DELIMITER}")
    end

    private def content_lines(component : String) : Array(String)
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

    def dup
      raise Exception.new("Can't duplicate instance of singleton #{self.class}")
    end
  end
end
