require "http/client"

module IcalParser
  class ICSStream
    def self.read(filename : String) : Calendar
      stream = File.read(filename)
      CalendarParser.parser.parse(stream)
    end

    def self.read(address : URI) : Calendar
      if address.scheme == "webcal"
        address.scheme = "https"
      end
      response = HTTP::Client.get address
      stream = response.body
      CalendarParser.parser.parse(stream)
    end

    def self.read_calendars(filename : String) : Array(Calendar)
      stream = File.read(filename)
      parse_multiple(stream)
    end

    def self.read_calendars(address : URI) : Array(Calendar)
      if address.scheme == "webcal"
        address.scheme = "https"
      end
      response = HTTP::Client.get address
      stream = response.body
      parse_multiple(stream)
    end

    private def self.parse_single(stream : String) : Calendar
      object_regex = /^BEGIN:VCALENDAR.*?END:VCALENDAR/m

      if calendar_object = stream.match(object_regex)
        CalendarParser.parser.parse(calendar_object[0])
      else
        raise "No calendar objects found in stream"
      end

    end

    private def self.parse_multiple(stream : String) : Array(Calendar)
      object_regex = /^BEGIN:VCALENDAR.*?END:VCALENDAR/m

      calendar_objects = stream.scan(object_regex)
      calendar_objects.map do |calendar_object|
        CalendarParser.parser.parse(calendar_object[0])
      end
    end
  end
end
