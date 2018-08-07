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
end
