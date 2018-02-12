require "minitest/autorun"

require "/../src/iCalCr/event"

class EventTest < Minitest::Test
  def test_parses_string
    event_string = "SUMMARY:Lunchtime meeting
UID:ff808181-1fd7389e-011f-d7389ef9-00000003
DTSTART;TZID=America/New_York:20160420T120000
DURATION:PT1H"
    event = ICalCr::Event.new(event_string)
    assert_equal "Lunchtime meeting", event.summary
    assert_equal "ff808181-1fd7389e-011f-d7389ef9-00000003", event.uid
    assert_equal Time.epoch(1461153600), event.start
  end
end
