require "minitest/autorun"
require "uri"

require "/../src/iCal"

class ICSStreamTest < Minitest::Test
  include IcalParser

  def test_parses_local_file
    filename = File.join(File.dirname(__FILE__), "files", "FIFA_World_Cup_2018.ics")
    calendars = ICSStream.read(filename)
    assert_equal Array(Calendar), calendars.class
    assert_equal 1, calendars.size
    calendar = calendars.first
    assert_equal "-//Calendar Labs//Calendar 1.0//EN", calendar.prodid
    assert_equal 64, calendar.events.size
    assert_equal Event, calendar.events.first.class
  end

  def test_parses_remote_stream
    address = "webcal://www.calendarlabs.com/ical-calendar/ics/196/FIFA_World_Cup_2018.ics"
    uri = URI.parse(address)
    calendars = ICSStream.read(uri)
    assert_equal Array(Calendar), calendars.class
    assert_equal 1, calendars.size
  end
end
