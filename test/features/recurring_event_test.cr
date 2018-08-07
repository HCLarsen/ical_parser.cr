require "minitest/autorun"

require "/../src/iCal"

class RecurringEventTest < Minitest::Test
  include IcalParser

  def test_recurring_event
    recur = RecurranceRule.new(RecurranceRule::Freq::Yearly)
    props = {
      "uid"     => "canada-day@example.com",
      "dtstamp" => Time.utc(1867, 3, 29, 13, 0, 0),
      "dtstart" => Time.utc(1867, 7, 1),
      "recurrance"   => recur
    } of String => PropertyType
    event = IcalParser::Event.new(props)
    assert event.recurring
    assert_equal RecurranceRule::Freq::Yearly, event.recurrance.not_nil!.frequency
  end

  def test_non_recurring_event_returns_single_element_array
    props = {
      "uid"     => "19970901T130000Z-123401@example.com",
      "dtstamp" => Time.utc(1997, 9, 1, 13, 0, 0),
      "dtstart" => Time.utc(1997, 9, 3, 16, 30, 0),
      "dtend"   => Time.utc(1997, 9, 3, 19, 0, 0),
    } of String => PropertyType
    event = IcalParser::Event.new(props)
    refute event.recurring
    assert_equal [event], event.occurences
  end
end
