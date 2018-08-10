require "minitest/autorun"

require "/../src/iCal"

class RecurringEventTest < Minitest::Test
  include IcalParser

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
    assert_equal event, event.occurences.first
    third_event = Event.new(props["uid"].as(String), props["dtstamp"].as(Time), Time.utc(1870, 7, 1))
    assert_equal third_event, event.occurences[3]
  end

  def test_recurring_event_with_count
    recur = RecurranceRule.new(RecurranceRule::Freq::Daily, 5, 10)
    props = {
      "uid"     => "canada-day@example.com",
      "dtstamp" => Time.utc(1997, 9, 2, 9, 0, 0),
      "dtstart" => Time.utc(1997, 9, 2, 9, 0, 0),
      "recurrance"   => recur
    } of String => PropertyType
    event = IcalParser::Event.new(props)
    assert_equal 5, event.occurences.size
    last_event = Event.new(props["uid"].as(String), props["dtstamp"].as(Time), Time.utc(1997, 10, 12, 9, 0, 0))
    assert_equal last_event, event.occurences.last
  end

  def test_recurring_event_with_until
    recur = RecurranceRule.new(RecurranceRule::Freq::Weekly, Time.new(1997, 12, 24))
    props = {
      "uid"     => "canada-day@example.com",
      "dtstamp" => Time.new(1997, 9, 2, 9, 0, 0),
      "dtstart" => Time.new(1997, 9, 2, 9, 0, 0),
      "recurrance"   => recur
    } of String => PropertyType
    event = IcalParser::Event.new(props)
    assert_equal 17, event.occurences.size
    assert_equal Time.new(1997, 12, 23, 9, 0, 0), event.occurences.last.dtstart
  end
end
