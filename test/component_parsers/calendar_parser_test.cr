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
    BEGIN:VCALENDAR
    VERSION:2.0
    PRODID:-//hacksw/handcal//NONSGML v1.0//EN
    BEGIN:VEVENT
    UID:19970610T172345Z-AF23B2@example.com
    DTSTAMP:19970610T172345Z
    DTSTART:19970714T170000Z
    DTEND:19970715T040000Z
    SUMMARY:Bastille Day Party
    END:VEVENT
    END:VCALENDAR
    HEREDOC
    calendar = @parser.parse(calendar_object)
    assert_equal "-//hacksw/handcal//NONSGML v1.0//EN", calendar.prodid
    assert_equal 1, calendar.events.size
    assert_equal "Bastille Day Party", calendar.events.first.summary
  end
end
