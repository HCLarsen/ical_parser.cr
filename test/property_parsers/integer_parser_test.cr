require "minitest/autorun"

require "/../src/iCal"

class IntegerParserTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, Int32)

  def initialize(arg)
    super(arg)
    @parser = @@integer_parser
  end

  def test_parses_small_integer
    string = "5"
    assert_equal 5, @parser.call(string)
  end

  def test_parses_large_negative_integer
    string = "-1234567890"
    assert_equal -1234567890, @parser.call(string)
  end

  def test_raises_for_invalid_float
    string = "SOMETHING ELSE"
    error = assert_raises do
      @parser.call(string)
    end
    assert_equal "Invalid Int32: SOMETHING ELSE", error.message
  end
end
