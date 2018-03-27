require "minitest/autorun"

require "/../src/ICal/parser"

class ParserTest < Minitest::Test
  def test_should_parse_event_from_iCal_with_one_event
    filename = File.join(File.dirname(__FILE__), "files", "test.ics")
    events = ICal::Parser.parse_events(filename)
    assert_equal Array(ICal::Event), events.class
    assert_equal 1, events.size
    assert_equal "Lunchtime meeting", events.first.summary
  end

  def test_should_parse_event_from_iCal_with_one_large_event
    filename = File.join(File.dirname(__FILE__), "files", "e122768155051111.ics")
    events = ICal::Parser.parse_events(filename)
    assert_equal Array(ICal::Event), events.class
    assert_equal 1, events.size
  end

  def test_should_parse_event_from_iCal_with_many_events
    filename = File.join(File.dirname(__FILE__), "files", "manu.ics")
    events = ICal::Parser.parse_events(filename)
    assert_equal Array(ICal::Event), events.class
    assert_equal 60, events.size
  end
end
