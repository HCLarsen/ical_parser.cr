require "minitest/autorun"

require "/../src/ical_parser/property_parsers/period_of_time_parser"
require "/../src/ical_parser/common"

class PeriodOfTimeTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, Hash(String, String), String)

  def initialize(arg)
    super(arg)
    @parser = @@period_parser
    @params = Hash(String, String).new
  end

  def test_parses_start_end_format
    string = "19970101T180000Z/19970102T070000Z"
    result = @parser.call(string, @params)
    start = Time.utc(1997, 1, 1, 18, 0, 0)
    finish = Time.utc(1997, 1, 2, 7, 0, 0)
    expected = %({"start":"1997-01-01T18:00:00Z","end":"1997-01-02T07:00:00Z"})
    assert_equal expected, result
  end

  def test_parses_start_duration_format
    string = "19970101T180000Z/PT5H30M"
    result = @parser.call(string, @params)
    start = Time.utc(1997, 1, 1, 18, 0, 0)
    duration = Time::Span.new(5, 30, 0)
    expected = %({"start":"1997-01-01T18:00:00Z","duration":{"hours":5,"minutes":30}})
    assert_equal expected, result
  end

  def test_raises_invalid_format
    string = "19970101T180000ZPT5H30M"
    error = assert_raises do
      period = @parser.call(string, @params)
    end
    assert_equal "Invalid Period of Time format", error.message
  end
end
