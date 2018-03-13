require "./event"

class ICal::Parser
  EVENT_REGEX = /(?s)(?<=BEGIN:VEVENT\n)(.*)(?=END:VEVENT)/

  def self.parse_events(filename : String) : Array(Event)
    string = File.read(filename)
    matches = EVENT_REGEX.match(string)
    if matches
      matches.captures.compact.map do |match|
        Event.new(match)
      end
    else
      [] of Event
    end
  end
end
