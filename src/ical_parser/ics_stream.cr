require "http/client"

module IcalParser
  class ICSStream
    def self.read(filename : String)
      stream = File.read(filename)
      parse(stream)
    end

    def self.read(address : URI)
      response = HTTP::Client.get address
      stream = response.body
      parse(stream)
    end

    private def self.parse(stream : String)
      object_regex = /^BEGIN:VCALENDAR.*?END:VCALENDAR/m

      calendar_objects = stream.scan(object_regex)
      calendar_objects.map do |calendar_object|
        CalendarParser.parser.parse(calendar_object[0])
      end
    end
  end
end
