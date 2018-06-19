require "minitest/autorun"

require "/../src/iCal"

class IntegerParserTest < Minitest::Test
  include IcalParser

  def initialize(arg)
    super(arg)
    @parser = IntegerParser.parser
  end

  def test_parses_small_integer
    assert_equal 5, @parser.parse("5")
  end

  def test_parses_large_negative_integer
    assert_equal -1234567890, @parser.parse("-1234567890")
  end

  def test_raises_for_invalid_float
    string = "SOMETHING ELSE"
    error = assert_raises do
      @parser.parse(string)
    end
    assert_equal "Invalid Int32: SOMETHING ELSE", error.message
  end
end
