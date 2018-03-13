require "./event"

class ICal::Parser
  def self.parse_events(filename : String)
    string = File.read(filename)
  end
end
