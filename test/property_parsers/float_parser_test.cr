require "minitest/autorun"

require "/../src/iCal"

class FloatParserTest < Minitest::Test
  include IcalParser

  def initialize(arg)
    super(arg)
    @parser = FloatParser.parser
  end

  def test_parses_large_float
    string = "1000000.0000001"
    float = 1000000.0000001
    assert_equal float, @parser.parse(string)
  end

  def test_parses_small_float
    string = "1.333"
    float = 1.333
    assert_equal float, @parser.parse(string)
  end

  def test_parses_negative_pi
    string = "-3.14"
    float = -3.14
    assert_equal float, @parser.parse(string)
  end

  def test_raises_for_invalid_float
    string = "SOMETHING ELSE"
    error = assert_raises do
      @parser.parse(string)
    end
    assert_equal "Invalid Float64: SOMETHING ELSE", error.message
  end
end
