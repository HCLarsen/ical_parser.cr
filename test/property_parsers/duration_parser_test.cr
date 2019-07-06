require "minitest/autorun"

require "/../src/ical_parser/property_parsers/duration_parser"
require "/../src/ical_parser/common"
# require "/../src/iCal"

class DurationParserTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, String)

  def initialize(arg)
    super(arg)
    @parser = @@duration_parser
  end

  def test_parses_simple_duration
    string = "PT1H"
    duration = @parser.call(string)
    assert_equal string, duration
  end

  def test_parses_duration_with_multiple_elements
    string = "P15DT5H0M20S"
    duration = @parser.call(string)
    assert_equal string, duration
  end

  def test_parses_weeklong_duration
    string = "P7W"
    duration = @parser.call(string)
    assert_equal string, duration
  end

  def test_parses_negative_duration
    string = "-PT15M"
    duration = @parser.call(string)
    assert_equal string, duration
  end

  def test_raises_on_invalid_durations
    durations = ["P15D5H0M20S", "P1H", "15D", "P1Y", "P1M", "P1WT1H"]
    durations.each do |duration|
      error = assert_raises do
        @parser.call(duration)
      end
      assert_equal "Invalid Duration format", error.message
    end
  end
end
