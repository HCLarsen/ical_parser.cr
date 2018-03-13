require "minitest/autorun"

require "/../src/ICal/parser"

class ParserTest < Minitest::Test
  def test_should_parse_events_from_iCal
    filename = File.join(File.dirname(__FILE__), "files", "test.ics")
    events = ICal::Parser.parse_events(filename)
    puts events
  end
end
