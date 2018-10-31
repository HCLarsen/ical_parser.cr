require "minitest/autorun"

require "/../src/iCal"

class DurationParserTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, Hash(String, String), Time::Span)

  def initialize(arg)
    super(arg)
    @parser = @@duration_parser
    @params = Hash(String, String).new
  end

  def test_parses_simple_duration
    string = "PT1H"
    assert_equal Time::Span.new(0, 1, 0, 0), @parser.call(string, @params)
  end

  def test_parses_duration_with_multiple_elements
    string = "P15DT5H0M20S"
    assert_equal Time::Span.new(15, 5, 0, 20), @parser.call(string, @params)
  end

  def test_parses_weeklong_duration
    string = "P7W"
    assert_equal Time::Span.new(49, 0, 0, 0), @parser.call(string, @params)
  end

  def test_parses_negative_duration
    string = "-PT15M"
    assert_equal Time::Span.new(0, 0, -15, 0), @parser.call(string, @params)
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
