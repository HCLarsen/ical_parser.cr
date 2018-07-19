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
    assert_equal CalAddress.new(URI.parse("mailto:jdoe@example.com")), event.organizer

    assert_equal 2, event.attendees.size
    assert_equal CalAddress.new(URI.parse("mailto:jsmith@example.com")), event.attendees.first
    assert_equal CalAddress.new(URI.parse("mailto:janedoe@example.com")), event.attendees.last
  end
end
