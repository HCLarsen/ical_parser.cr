require "minitest/autorun"

require "/../src/iCal"

class DateTimeParserTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, Hash(String, String), Time)

  def initialize(arg)
    super(arg)
    @parser = @@date_time_parser
    @params = Hash(String, String).new
  end

  def test_parses_floating_date_time
    string = "19980118T230000"
    dateTime = @parser.call(string, @params)
    assert_equal Time.new(1998, 1, 18, 23, 0, 0), dateTime
    assert_equal Time::Location.local, dateTime.location
  end

  def test_parses_utc_date_time
    string = "19980119T070000Z"
    dateTime = @parser.call(string, @params)
    assert_equal Time.utc(1998, 1, 19, 7, 0, 0), dateTime
    assert_equal Time::Location::UTC, dateTime.location
  end

  def test_parses_date_time_with_time_zone
    string = "19970714T133000"
    params = {"TZID" => "America/New_York"}
    dateTime = @parser.call(string, params)
    assert_equal Time.utc(1997, 7, 14, 17, 30, 0), dateTime
    assert_equal Time::Location.load("America/New_York"), dateTime.location
  end

  def test_raises_for_invalid_time_format
    string = "19980119T230000-0800"
    error = assert_raises do
      @parser.call(string, @params)
    end
    assert_equal "Invalid Time format", error.message
  end

  def test_raises_for_invalid_date_time_format
    string = "19980119230000"
    error = assert_raises do
      @parser.call(string, @params)
    end
    assert_equal "Invalid Date-Time format", error.message
  end

  def test_raises_for_date_time_without_time
    string = "19980118T"
    error = assert_raises do
      @parser.call(string, @params)
    end
    assert_equal "Invalid Date-Time format", error.message
  end
end
