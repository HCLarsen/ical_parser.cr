require "minitest/autorun"

require "/../src/ical_parser/property_parsers/time_parser"
require "/../src/ical_parser/common"

class TimeParserTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, Hash(String, String), String)

  def initialize(arg)
    super(arg)
    @parser = @@time_parser
    @params = Hash(String, String).new
  end

  def test_parses_time
    string = "230000"
    time = @parser.call(string, @params)
    assert_equal string, time
  end

  def test_parses_utc_time
    string = "070000Z"
    time = @parser.call(string, @params)
    assert_equal string, time
  end

  def test_parses_est_time_zone_time
    string = "083000"
    time = @parser.call(string, @params)
    assert_equal string, time
  end

  def test_raises_invalid_time_format
    string = "230000-0800"
    error = assert_raises do
      @parser.call(string, @params)
    end
    assert_equal "Invalid Time format", error.message
  end
end
