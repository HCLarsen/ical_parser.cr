require "minitest/autorun"

require "/../src/iCal"

class CalendarTest < Minitest::Test
  include IcalParser

  def initialize(argument)
    super(argument)
    @prodid = "-//hacksw/handcal//NONSGML v1.0//EN"
  end

  def test_initializes_calendar_with_single_event
    event = Event.new("19970610T172345Z-AF23B2@example.com", Time.utc(1997, 6, 10, 17, 23, 45), Time.utc(1997, 7, 14, 17, 0, 0), Time.utc(1997, 7, 15, 4, 0, 0))
    calendar = Calendar.new(@prodid, [event])
    assert_equal @prodid, calendar.prodid
    assert_equal event, calendar.events.first
  end

  # JSON Tests
  def test_parses_from_json
    json = %({"version":"2.0","prodid":"-//hacksw/handcal//NONSGML v1.0//EN","events":[{"uid":"19970610T172345Z-AF23B2@example.com","dtstamp":"1997-06-10T17:23:45Z","dtstart":"1997-07-14T17:00:00Z","dtend":"1997-07-15T04:00:00Z","summary":"Bastille Day Party"}]})

    calendar = Calendar.from_json(json)
    assert_equal "-//hacksw/handcal//NONSGML v1.0//EN", calendar.prodid
    assert_equal 1, calendar.events.size
    assert_equal "Bastille Day Party", calendar.events.first.summary
  end
end
