require "minitest/autorun"

require "/../src/ICal/event"

class EventTest < Minitest::Test
  def test_parses_event_with_duration
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
  end

  def test_parses_end_time
    event_string = <<-HEREDOC
    BEGIN:VEVENT
    UID:19970901T130000Z-123401@example.com
    DTSTAMP:19970901T130000Z
    DTSTART:19970903T163000Z
    DTEND:19970903T190000Z
    SUMMARY:Annual Employee Review
    CLASS:PRIVATE
    CATEGORIES:BUSINESS,HUMAN RESOURCES
    END:VEVENT
    HEREDOC
    event = ICal::Event.new(event_string)
    assert_equal "Annual Employee Review", event.summary
    assert_equal Time.new(1997, 9, 3, 16, 30, 0, nanosecond: 0, kind: Time::Kind::Utc), event.start
    assert_equal Time.new(1997, 9, 3, 19, 0, 0, nanosecond: 0, kind: Time::Kind::Utc), event.end
  end
end
