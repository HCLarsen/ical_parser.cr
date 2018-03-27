require "./event"

class ICal::Parser
  EVENT_REGEX = /(?s)BEGIN:VEVENT(.*?)END:VEVENT/

  def self.parse_events(filename : String) : Array(Event)
    string = File.read(filename)
    matches = string.scan(EVENT_REGEX)
    if matches
      matches.map do |match|
        Event.new(match.not_nil![1])
      end
    else
      [] of Event
    end
  end
end
