require "minitest/autorun"

require "/../src/iCal"

class PeriodOfTimeTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, Hash(String, String), PeriodOfTime)

  def initialize(arg)
    super(arg)
    @parser = @@period_parser
    @params = Hash(String, String).new
  end

  def test_parses_start_end_format
    string = "19970101T180000Z/19970102T070000Z"
    period = @parser.call(string, @params)
    start = Time.utc(1997, 1, 1, 18, 0, 0)
    finish = Time.utc(1997, 1, 2, 7, 0, 0)
    assert_equal start, period.start_time
    assert_equal finish, period.end_time
    assert_equal finish - start, period.duration
  end

  def test_parses_start_duration_format
    string = "19970101T180000Z/PT5H30M"
    period = @parser.call(string, @params)
    start = Time.utc(1997, 1, 1, 18, 0, 0)
    duration = Time::Span.new(5, 30, 0)
    assert_equal start, period.start_time
    assert_equal duration, period.duration
    assert_equal start + duration, period.end_time
  end

  def test_raises_invalid_format
    string = "19970101T180000ZPT5H30M"
    error = assert_raises do
      period = @parser.call(string, @params)
    end
    assert_equal "Invalid Period of Time format", error.message
  end
end
