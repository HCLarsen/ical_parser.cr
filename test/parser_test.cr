require "minitest/autorun"

require "/../src/ICal/parser"

class ParserTest < Minitest::Test
  def test_should_parse_event_from_iCal_with_one_event
    filename = File.join(File.dirname(__FILE__), "files", "test.ics")
    events = ICal::Parser.parse_events(filename)
    assert_equal events.class, Array(ICal::Event)
    assert_equal events.size, 1
    assert_equal events.first.summary, "Lunchtime meeting"
  end

  # Need to find a ics feed with events using datetime instead of dates.
  def test_should_parse_event_from_iCal_with_many_events
    filename = File.join(File.dirname(__FILE__), "files", "manu.ics")
    events = ICal::Parser.parse_events(filename)
    assert_equal Array(ICal::Event), events.class
    assert_equal 60, events.size
  end
end
