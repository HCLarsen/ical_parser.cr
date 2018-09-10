require "minitest/autorun"

require "/../src/iCal"

class CalendarParserTest < Minitest::Test
  include IcalParser

  def initialize(argument)
    super(argument)
    @parser = CalendarParser.parser
  end

  def test_parses_simple_calendar
    calendar_object = <<-HEREDOC
    BEGIN:VCALENDAR\r
    VERSION:2.0\r
    PRODID:-//hacksw/handcal//NONSGML v1.0//EN\r
    BEGIN:VEVENT\r
    UID:19970610T172345Z-AF23B2@example.com\r
    DTSTAMP:19970610T172345Z\r
    DTSTART:19970714T170000Z\r
    DTEND:19970715T040000Z\r
    SUMMARY:Bastille Day Party\r
    END:VEVENT\r
    END:VCALENDAR
    HEREDOC
    calendar = @parser.parse(calendar_object)
    assert_equal "-//hacksw/handcal//NONSGML v1.0//EN", calendar.prodid
    assert_equal 1, calendar.events.size
    assert_equal "Bastille Day Party", calendar.events.first.summary
  end

  def test_parses_complex_calendar
    calendar_object = <<-HEREDOC
    BEGIN:VCALENDAR\r
    METHOD:xyz\r
    VERSION:2.0\r
    PRODID:-//ABC Corporation//NONSGML My Product//EN\r
    BEGIN:VEVENT\r
    DTSTAMP:19970324T120000Z\r
    SEQUENCE:0\r
    UID:uid3@example.com\r
    ORGANIZER:mailto:jdoe@example.com\r
    ATTENDEE;RSVP=TRUE:mailto:jsmith@example.com\r
    ATTENDEE;RSVP=TRUE:mailto:janedoe@example.com\r
    DTSTART:19970324T123000Z\r
    DTEND:19970324T210000Z\r
    CATEGORIES:MEETING,PROJECT\r
    CLASS:PUBLIC\r
    SUMMARY:Calendaring Interoperability Planning Meeting\r
    DESCRIPTION:Discuss how we can test c&s interoperability\\nusing iCalendar and other IETF standards.\r
    LOCATION:LDB Lobby\r
    URL:http://example.com/pub/calendars/jsmith/mytime.ics
    ATTACH;FMTTYPE=application/postscript:ftp://example.com/pub/\r
     conf/bkgrnd.ps\r
    END:VEVENT\r
    END:VCALENDAR
    HEREDOC
    calendar = @parser.parse(calendar_object)
    assert_equal 1, calendar.events.size
    event = calendar.events.first
    assert_equal "LDB Lobby", event.location
    assert_equal 0, event.sequence
    assert_equal URI.parse("http://example.com/pub/calendars/jsmith/mytime.ics"), event.url
    assert_equal CalAddress.new(URI.parse("mailto:jdoe@example.com")), event.organizer

    assert_equal 2, event.attendees.size
    assert_equal CalAddress.new(URI.parse("mailto:jsmith@example.com")), event.attendees.first
    assert_equal CalAddress.new(URI.parse("mailto:janedoe@example.com")), event.attendees.last
  end

  def test_parses_event_with_time_zone
    calendar_object = <<-HEREDOC
    BEGIN:VCALENDAR
    PRODID:-//RDU Software//NONSGML HandCal//EN
    VERSION:2.0
    BEGIN:VTIMEZONE
    TZID:America/New_York
    BEGIN:STANDARD
    DTSTART:19981025T020000
    TZOFFSETFROM:-0400
    TZOFFSETTO:-0500
    TZNAME:EST
    END:STANDARD
    BEGIN:DAYLIGHT
    DTSTART:19990404T020000
    TZOFFSETFROM:-0500
    TZOFFSETTO:-0400
    TZNAME:EDT
    END:DAYLIGHT
    END:VTIMEZONE
    BEGIN:VEVENT
    DTSTAMP:19980309T231000Z
    UID:guid-1.example.com
    ORGANIZER:mailto:mrbig@example.com
    ATTENDEE;RSVP=TRUE;ROLE=REQ-PARTICIPANT;CUTYPE=GROUP:
     mailto:employee-A@example.com
    DESCRIPTION:Project XYZ Review Meeting
    CATEGORIES:MEETING
    CLASS:PUBLIC
    CREATED:19980309T130000Z
    LAST-MODIFIED:19980309T150500Z
    SUMMARY:XYZ Project Review
    DTSTART;TZID=America/New_York:19980312T083000
    DTEND;TZID=America/New_York:19980312T093000
    LOCATION:1CP Conference Room 4350
    END:VEVENT
    END:VCALENDAR
    HEREDOC
    calendar = @parser.parse(calendar_object)
    event = calendar.events.first
    assert_equal Time.utc(1998, 3, 9, 13, 0, 0), event.created
    assert_equal Time.utc(1998, 3, 9, 15, 5, 0), event.last_mod
  end
end
