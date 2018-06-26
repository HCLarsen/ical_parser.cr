require "minitest/autorun"

require "/../src/iCal"

class DateTimeParserTest < Minitest::Test
  include IcalParser

  def initialize(arg)
    super(arg)
    @parser = DateTimeParser.parser
  end

  def test_parses_floating_date_time
    dateTime = @parser.parse("19980118T230000")
    assert_equal Time.new(1998, 1, 18, 23, 0, 0), dateTime
    assert_equal Time::Location.local, dateTime.location
  end

  def test_parses_utc_date_time
    dateTime = @parser.parse("19980119T070000Z")
    assert_equal Time.utc(1998, 1, 19, 7, 0, 0), dateTime
    assert_equal Time::Location::UTC, dateTime.location
  end

  def test_parses_date_time_with_time_zone
    string = "19970714T133000"
    params = { "TZID" => "America/New_York" }
    dateTime = @parser.parse(string, params)
    assert_equal Time.utc(1997, 7, 14, 17, 30, 0), dateTime
    assert_equal Time::Location.load("America/New_York"), dateTime.location
  end

  def test_raises_for_invalid_time_format
    error = assert_raises do
      @parser.parse("19980119T230000-0800")
    end
    assert_equal "Invalid Time format", error.message
  end

  def test_raises_for_invalid_date_time_format
    error = assert_raises do
      @parser.parse("19980119230000")
    end
    assert_equal "Invalid Date-Time format", error.message
  end

  def test_raises_for_date_time_without_time
    error = assert_raises do
      @parser.parse("19980118T")
    end
    assert_equal "Invalid Date-Time format", error.message
  end
end
