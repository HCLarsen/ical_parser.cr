require "minitest/autorun"

require "/../src/ical_parser/property_parsers/duration_parser"
require "/../src/ical_parser/common"

class DurationParserTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, Hash(String, String), String)

  def initialize(arg)
    super(arg)
    @parser = @@duration_parser
    @params = Hash(String, String).new
  end

  def test_parses_simple_duration
    string = "PT1H"
    assert_equal %({"hours":1}), @parser.call(string, @params)
  end

  def test_parses_duration_with_multiple_elements
    string = "P15DT5H0M20S"
    assert_equal %({"days":15,"hours":5,"minutes":0,"seconds":20}), @parser.call(string, @params)
  end

  def test_parses_weeklong_duration
    string = "P7W"
    assert_equal %({"weeks":7}), @parser.call(string, @params)
  end

  def test_parses_negative_duration
    string = "-PT1H15M"
    assert_equal %({"hours":-1,"minutes":-15}), @parser.call(string, @params)
  end

  def test_raises_on_invalid_durations
    durations = ["P15D5H0M20S", "P1H", "15D", "P1Y", "P1M", "P1WT1H"]
    durations.each do |duration|
      error = assert_raises do
        @parser.call(duration, @params)
      end
      assert_equal "Invalid Duration format", error.message
    end
  end
end
