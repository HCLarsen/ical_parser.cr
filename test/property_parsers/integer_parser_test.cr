require "minitest/autorun"

require "/../src/ical_parser/property_parsers/integer_parser"
require "/../src/ical_parser/common"

class IntegerParserTest < Minitest::Test
  include IcalParser

  @parser : Proc(String, Hash(String, String), String)

  def initialize(arg)
    super(arg)
    @parser = @@integer_parser
    @params = Hash(String, String).new
  end

  def test_parses_small_integer
    string = "5"
    assert_equal string, @parser.call(string, @params)
  end

  def test_parses_large_negative_integer
    string = "-1234567890"
    assert_equal string, @parser.call(string, @params)
  end

  def test_raises_for_invalid_float
    string = "SOMETHING ELSE"
    error = assert_raises do
      @parser.call(string, @params)
    end
    assert_equal "Invalid Int32: SOMETHING ELSE", error.message
  end
end
