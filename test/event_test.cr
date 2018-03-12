require "minitest/autorun"

require "/../src/ICal/event"

class EventTest < Minitest::Test
  def test_parses_string
    event_string = <<-HEREDOC
    BEGIN:VEVENT
    SUMMARY:Lunchtime meeting
    UID:ff808181-1fd7389e-011f-d7389ef9-00000003
    DTSTART;TZID=America/New_York:20160420T120000
    DURATION:PT1H
    DESCRIPTION: We'll continue with the unfinished business from last time,\n
      in particular:\n
      Can names start with a number?\n
      What if they are all numeric?\n
      Reuse of names - is it valid\n
      I remind the attendees we have spent 3 months on these subjects. We need
      closure!!!
    LOCATION:Mo's bar - back room
    END:VEVENT
    HEREDOC
    event = ICal::Event.new(event_string)
    assert_equal "Lunchtime meeting", event.summary
    assert_equal "ff808181-1fd7389e-011f-d7389ef9-00000003", event.uid
    assert_equal Time.new(2016, 4, 20, 12, 0, 0, nanosecond: 0, kind: Time::Kind::Local), event.start
    assert_equal Time.new(2016, 4, 20, 13, 0, 0, nanosecond: 0, kind: Time::Kind::Local), event.end
    #Time.new(2016, 4, 20, 12, 0, 0, nanosecond: 0, kind: Time::Kind::Local)
  end
end
