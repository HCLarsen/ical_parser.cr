require "minitest/autorun"

require "/../src/ical_parser/property_parsers/period_of_time_parser"
require "/../src/ical_parser/common"

class PeriodOfTimeTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, String)

  def initialize(arg)
    super(arg)
    @parser = @@period_parser
  end

  def test_parses_start_end_format
    string = "19970101T180000Z/19970102T070000Z"
    period = @parser.call(string)
    json = %({"start":"19970101T180000Z","finish":"19970102T070000Z"})
    assert_equal json, period
  end

  def test_parses_start_duration_format
    string = "19970101T180000Z/PT5H30M"
    period = @parser.call(string)
    json = %({"start":"19970101T180000Z","duration":"PT5H30M"})
    assert_equal json, period
  end

  def test_raises_invalid_format
    string = "19970101T180000ZPT5H30M"
    error = assert_raises do
      period = @parser.call(string)
    end
    assert_equal "Invalid Period of Time format", error.message
  end
end
