require "minitest/autorun"
require "uri"

require "/../src/iCal"

class ICSStreamTest < Minitest::Test
  include IcalParser
  TEST_FILE_FOLDER = File.join(File.dirname(File.dirname(__FILE__)), "files")

  def test_parses_local_file
    filename = File.join(TEST_FILE_FOLDER, "FIFA_World_Cup_2018.ics")
    calendar = ICSStream.read(filename)
    assert_equal Calendar, calendar.class
    assert_equal "-//Calendar Labs//Calendar 1.0//EN", calendar.prodid
    assert_equal 64, calendar.events.size
    assert_equal Event, calendar.events.first.class
  end

  def test_parses_remote_stream
    address = "webcal://www.calendarlabs.com/ical-calendar/ics/196/FIFA_World_Cup_2018.ics"
    uri = URI.parse(address)
#    calendar = ICSStream.read(uri)
#    assert_equal Calendar, calendar.class
  end

  def test_parses_local_file_as_array
    filename = File.join(TEST_FILE_FOLDER, "multical.ics")
    calendars = ICSStream.read_calendars(filename)
    assert_equal Array(Calendar), calendars.class
    assert_equal 2, calendars.size
    calendar = calendars.first
    event = calendar.events.first
    assert_equal "Networld+Interop Conference and Exhibit\\nAtlanta World Congress Center\\nAtlanta, Georgia", event.description
    assert_equal "CONFIRMED", event.status
    assert_equal ["CONFERENCE"], event.categories
  end

  def test_parses_remote_stream_as_array
    address = "webcal://www.calendarlabs.com/ical-calendar/ics/196/FIFA_World_Cup_2018.ics"
    uri = URI.parse(address)
#    calendars = ICSStream.read_calendars(uri)
#    assert_equal Array(Calendar), calendars.class
#    assert_equal 1, calendars.size
  end

  def test_raises_for_non_calendar_stream
    filename = File.join(File.dirname(__FILE__), "files", "invalid.ics")
    assert_raises do
      calendar = ICSStream.read(filename)
    end
  end
end
