require "http/client"

module IcalParser
  class ICSStream
    def self.read(filename : String) : Calendar
      stream = File.read(filename)
      parse(stream).first
    end

    def self.read(address : URI) : Calendar
      response = HTTP::Client.get make_https(address)
      stream = response.body
      parse(stream).first
    end

    def self.read_calendars(filename : String) : Array(Calendar)
      stream = File.read(filename)
      parse(stream)
    end

    def self.read_calendars(address : URI) : Array(Calendar)
      response = HTTP::Client.get make_https(address)
      stream = response.body
      parse(stream)
    end

    private def self.parse(stream : String) : Array(Calendar)
      object_regex = /^BEGIN:VCALENDAR.*?END:VCALENDAR/m

      calendar_objects = stream.scan(object_regex)

      if calendar_objects.size == 0
        raise "No calendar objects found in stream"
      end

      calendar_objects.map do |calendar_object|
        CalendarParser.parser.parse(calendar_object[0])
      end
    end

    private def self.make_https(address : URI)
      address.scheme = "https" if address.scheme == "webcal"

      return address
    end
  end
end
