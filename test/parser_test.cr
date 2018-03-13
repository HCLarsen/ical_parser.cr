require "minitest/autorun"

require "/../src/ICal/parser"

class ParserTest < Minitest::Test
  def test_should_parse_events_from_iCal
    filename = File.join(File.dirname(__FILE__), "files", "test.ics")
    events = ICal::Parser.parse_events(filename)
    assert_equal events.class, Array(ICal::Event)
    assert_equal events.size, 1
    assert_equal events.first.summary, "Lunchtime meeting"
  end
end
