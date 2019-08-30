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
    BEGIN:VCALENDAR\r
    PRODID:-//RDU Software//NONSGML HandCal//EN\r
    VERSION:2.0\r
    BEGIN:VTIMEZONE\r
    TZID:America/New_York\r
    BEGIN:STANDARD\r
    DTSTART:19981025T020000\r
    TZOFFSETFROM:-0400\r
    TZOFFSETTO:-0500\r
    TZNAME:EST\r
    END:STANDARD\r
    BEGIN:DAYLIGHT\r
    DTSTART:19990404T020000\r
    TZOFFSETFROM:-0500\r
    TZOFFSETTO:-0400\r
    TZNAME:EDT\r
    END:DAYLIGHT\r
    END:VTIMEZONE\r
    BEGIN:VEVENT\r
    DTSTAMP:19980309T231000Z\r
    UID:guid-1.example.com\r
    ORGANIZER:mailto:mrbig@example.com\r
    ATTENDEE;RSVP=TRUE;ROLE=REQ-PARTICIPANT;CUTYPE=GROUP:
     mailto:employee-A@example.com\r
    DESCRIPTION:Project XYZ Review Meeting\r
    CATEGORIES:MEETING\r
    CLASS:PUBLIC\r
    CREATED:19980309T130000Z\r
    LAST-MODIFIED:19980309T150500Z\r
    SUMMARY:XYZ Project Review\r
    DTSTART;TZID=America/New_York:19980312T083000\r
    DTEND;TZID=America/New_York:19980312T093000\r
    LOCATION:1CP Conference Room 4350\r
    END:VEVENT\r
    END:VCALENDAR
    HEREDOC
    calendar = @parser.parse(calendar_object)
    event = calendar.events.first
    assert_equal Time.utc(1998, 3, 9, 13, 0, 0), event.created
    assert_equal Time.utc(1998, 3, 9, 15, 5, 0), event.last_modified
  end

  #JSON tests
  def test_parses_simple_calendar_to_json
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

    expected = %({"version":"2.0","prodid":"-//hacksw/handcal//NONSGML v1.0//EN","events":[{"uid":"19970610T172345Z-AF23B2@example.com","dtstamp":"1997-06-10T17:23:45Z","dtstart":"1997-07-14T17:00:00Z","dtend":"1997-07-15T04:00:00Z","summary":"Bastille Day Party"}]})

    calendar = @parser.parse_to_json(calendar_object)
    assert_equal expected, calendar
  end
end
