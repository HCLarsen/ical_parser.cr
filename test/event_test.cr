require "minitest/autorun"

require "/../src/ICal/parser"
require "./ics_stream"

class EventTest < Minitest::Test

  def test_parses_event_with_duration
    event_string = <<-HEREDOC
    BEGIN:VEVENT
    SUMMARY:Lunchtime meeting
    UID:ff808181-1fd7389e-011f-d7389ef9-00000003
    DTSTART;TZID=America/New_York:20160420T120000
    DURATION:PT1H
    DESCRIPTION: We'll continue with the unfinished business from last time,
     in particular:
       Can names dtstart with a number?
       What if they are all numeric?
       Reuse of names - is it valid
     I remind the attendees we have spent 3 months on these subjects. We need
     closure!!!
    LOCATION:Mo's bar - back room
    END:VEVENT
    HEREDOC

    descriptionString = <<-DESCRIPTION_STRING
    We'll continue with the unfinished business from last time,
     in particular:
       Can names dtstart with a number?
       What if they are all numeric?
       Reuse of names - is it valid
     I remind the attendees we have spent 3 months on these subjects. We need
     closure!!!
    DESCRIPTION_STRING

    event = ICal::Event.new(event_string)
    assert_equal "Lunchtime meeting", event.summary
    assert_equal "ff808181-1fd7389e-011f-d7389ef9-00000003", event.uid
    assert_equal Time.new(2016, 4, 20, 12, 0, 0, kind: Time::Kind::Local), event.dtstart
    assert_equal Time.new(2016, 4, 20, 13, 0, 0, kind: Time::Kind::Local), event.dtend
    assert_equal "Mo's bar - back room", event.location
    assert_equal descriptionString, event.description
    assert_equal false, event.allDay
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
    assert_equal Time.new(1997, 9, 3, 16, 30, 0, kind: Time::Kind::Utc), event.dtstart
    assert_equal Time.new(1997, 9, 3, 19, 0, 0, kind: Time::Kind::Utc), event.dtend
    assert event.description.nil?
    assert event.location.nil?
  end

  def test_parses_facebook_event
    event = ICal::Event.new(Fixture.facebook_event)
    assert_equal "OMD", event.summary
    assert_equal "https://www.facebook.com/events/122768155051111/", event.url
    assert_equal Time.new(2018, 3, 13, 23, 0, 0, kind: Time::Kind::Utc), event.dtstart
    assert_equal "The Danforth Music Hall", event.location
  end

  def test_raises_if_dtstart_absent
    event_string = <<-HEREDOC
    BEGIN:VEVENT
    UID:19970901T130000Z-123401@example.com
    DTSTAMP:19970901T130000Z
    DTEND:19970903T190000Z
    SUMMARY:Annual Employee Review
    CLASS:PRIVATE
    CATEGORIES:BUSINESS,HUMAN RESOURCES
    END:VEVENT
    HEREDOC
    response = assert_raises do
      event = ICal::Event.new(event_string)
    end
    assert_equal "Invalid Event: No DTSTART present", response.message
  end

  def test_parses_all_day_event
    event_string = <<-HEREDOC
    BEGIN:VEVENT
    UID:19970901T130000Z-123403@example.com
    DTSTAMP:19970901T130000Z
    DTSTART;VALUE=DATE:19971102
    SUMMARY:Our Blissful Anniversary
    TRANSP:TRANSPARENT
    CLASS:CONFIDENTIAL
    CATEGORIES:ANNIVERSARY,PERSONAL,SPECIAL OCCASION
    RRULE:FREQ=YEARLY
    END:VEVENT
    HEREDOC
    event = ICal::Event.new(event_string)
    assert event.allDay
    assert_equal event.dtstart, event.dtend
  end

  def test_parses_multi_day_event
    event_string = <<-HEREDOC
    BEGIN:VEVENT
    UID:20070423T123432Z-541111@example.com
    DTSTAMP:20070423T123432Z
    DTSTART;VALUE=DATE:20070628
    DTEND;VALUE=DATE:20070709
    SUMMARY:Festival International de Jazz de Montreal
    TRANSP:TRANSPARENT
    END:VEVENT
    HEREDOC
    event = ICal::Event.new(event_string)
    assert event.allDay
    assert_equal Time.new(2007, 6, 28), event.dtstart
    assert_equal Time.new(2007, 7, 9), event.dtend
  end
end
