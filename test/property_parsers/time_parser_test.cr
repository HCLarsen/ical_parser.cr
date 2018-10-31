require "minitest/autorun"

require "/../src/iCal"

class TimeParserTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, Hash(String, String), Time)

  def initialize(arg)
    super(arg)
    @parser = @@time_parser
    @params = Hash(String, String).new
  end

  def test_parses_time
    string = "230000"
    time = @parser.call(string, @params)
    assert_equal Time.new(1, 1, 1, 23, 0, 0, nanosecond: 0, location: Time::Location.local), time
    assert_equal Time::Location.local, time.location
  end

  def test_parses_utc_time
    string = "070000Z"
    time = @parser.call(string, @params)
    assert_equal Time.utc(1, 1, 1, 7, 0, 0), time
  end

  def test_parses_est_time_zone_time
    string = "083000"
    @params = {"TZID" => "America/New_York"}
    time = @parser.call(string, @params)
    assert_equal Time.utc(1, 1, 1, 13, 30, 0), time
    assert_equal Time::Location.load("America/New_York"), time.location
  end

  def test_raises_invalid_time_format
    string = "230000-0800"
    error = assert_raises do
      @parser.call(string, @params)
    end
    assert_equal "Invalid Time format", error.message
  end
end
