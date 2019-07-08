require "minitest/autorun"

require "/../src/ical_parser/property_parsers/float_parser"
require "/../src/ical_parser/common"

class FloatParserTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, Hash(String, String), String)

  def initialize(arg)
    super(arg)
    @parser = @@float_parser
    @params = Hash(String, String).new
  end

  def test_parses_large_float
    float = "1000000.0000001"
    assert_equal float, @parser.call(float, @params)
  end

  def test_parses_small_float
    float = "1.333"
    assert_equal float, @parser.call(float, @params)
  end

  def test_parses_negative_pi
    float = "-3.14"
    assert_equal float, @parser.call(float, @params)
  end

  def test_raises_for_invalid_float
    string = "SOMETHING ELSE"
    error = assert_raises do
      @parser.call(string, @params)
    end
    assert_equal "Invalid Float64: SOMETHING ELSE", error.message
  end
end
