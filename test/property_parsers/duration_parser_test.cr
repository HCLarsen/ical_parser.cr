require "minitest/autorun"

require "/../src/iCal"

class DurationParserTest < Minitest::Test
  include IcalParser

  def initialize(arg)
    super(arg)
    @parser = DurationParser.parser
  end

  def test_parses_simple_duration
    durationString = "PT1H"
    assert_equal Time::Span.new(0, 1, 0, 0), @parser.parse(durationString)
  end

  def test_parses_duration_with_multiple_elements
    durationString = "P15DT5H0M20S"
    assert_equal Time::Span.new(15, 5, 0, 20), @parser.parse(durationString)
  end

  def test_parses_weeklong_duration
    durationString = "P7W"
    assert_equal Time::Span.new(49, 0, 0, 0), @parser.parse(durationString)
  end

  def test_parses_negative_duration
    durationString = "-PT15M"
    assert_equal Time::Span.new(0, 0, -15, 0), @parser.parse(durationString)
  end

  def test_raises_on_invalid_durations
    durations = ["P15D5H0M20S", "P1H", "15D", "P1Y", "P1M", "P1WT1H"]
    durations.each do |duration|
      error = assert_raises do
        @parser.parse(duration)
      end
      assert_equal "Invalid Duration format", error.message
    end
  end
end
